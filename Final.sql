CREATE DATABASE Final

/*The customer table is created to record customer information.
It incorporates the customers' customerId, name, address and contact information.
It also contains the times of return that the customer has proceeded.
The field [customerId] is set as the primary key in the customer table. */
CREATE TABLE customer(
customerId VARCHAR(20) NOT NULL CONSTRAINT customer_pk PRIMARY KEY,
customerName VARCHAR(50) NOT NULL,
street VARCHAR(50) NOT NULL,
city VARCHAR(50) NOT NULL,
postalCode CHAR(6) NOT NULL,
email VARCHAR(50),
timesOfReturn INT NOT NULL DEFAULT 0,
actionTest VARCHAR(100)
)

/*The merchandise table is created to record all necessary merchandise information.
It includes both sold and unsold merchandises distinguished by the [isSold] column. Value 0 is set as unsold, and 1 is set as sold.
Also, there is a [actionTest] column created for testing the trigger.
The field [merchandiseId] is set as the primary key in the merchandise table*/

CREATE TABLE merchandise(
merchandiseId VARCHAR(20) NOT NULL CONSTRAINT merchandise_pk PRIMARY KEY,
merchandiseName VARCHAR(50) NOT NULL,
merchandiseType VARCHAR(20) NOT NULL,
price MONEY NOT NULL,
isSold BIT NOT NULL DEFAULT 0,
inputDate DATETIME DEFAULT GETDATE(),
actionTest VARCHAR(100)
)

/*The [returned_merchandise] table is created to record returned merchandise data.
It records every return that has been made along with the reason for returning.
Also, the foreign key [customerId] is referenced from the table [customer], column [customerId].
The foreign key [merchandiseId] is referenced from the table [merchandise], column [merchandiseId].
*/
CREATE TABLE returned_merchandise(
merchandiseId VARCHAR(20) NOT NULL,
customerId VARCHAR(20) NOT NULL,
reasonForReturn VARCHAR(200) NOT NULL,
inputDate DATETIME DEFAULT GETDATE(),

CONSTRAINT customer_fk 
FOREIGN KEY (customerId)
REFERENCES customer (customerId),

CONSTRAINT merchandise_fk
FOREIGN KEY (merchandiseId)
REFERENCES merchandise (merchandiseId)
)

GO 

CREATE TRIGGER trReturned_mcdAftInsert ON returned_merchandise
AFTER INSERT 
AS 
		DECLARE @MerchandiseId VARCHAR(20);
		DECLARE @CustomerId VARCHAR(20);
		DECLARE @ActionTest VARCHAR(100);
		DECLARE @CustomerActionTest VARCHAR(100);
		DECLARE @TimesOfReturn INT;

		SELECT @MerchandiseId = i.merchandiseId FROM INSERTED i;
		SELECT @CustomerId = i.customerId FROM INSERTED i;

		SET @ActionTest = 'Price updated - AFTER INSERT TRIGGER.';
		SET @CustomerActionTest = 'Times of Return recorded - AFTER INSERT TRIGGER';
		SET @TimesOfReturn += 1;

		UPDATE merchandise SET price = price * 0.9, inputDate = GETDATE(), 
		isSold = 0, actionTest = @ActionTest WHERE merchandiseId = @MerchandiseId;

		UPDATE customer SET timesOfReturn = timesOfReturn + 1, actionTest = @CustomerActionTest WHERE customerId = @CustomerId;
GO


/*   Description of the database design steps
There are three tables created to store information which are customer,
merchandise and returned_merchandise tables.

To enforce the business rule 1, I created an after insert trigger [trReturned_mcdAftInsert]
which binds on the [returned_merchandise] table. Whenever a sold merchandise gets returned,
its new price in the [merchandise] table will be updated as 90% of its original price,
and change the value of [isSold] column from 1(sold) to 0 (unsold).

To enforce the business rule 2, I created a column called [reasonForReturn], and set a not null
constraint for it. Therefore, every time a merchandise gets returned, the reason for returning
must be entered as well.

To enforce the business rule 3, I created a column called [timesOfReturn] to record the times that 
a customer has returned the company's merchandise. Also, the trigger [trReturned_mcdAftInsert]
was also used to count the times of returning. Every time a merchandise gets returned, the
customer whoever returns the merchandise will get +1 on the value of his column [timesOfReturn].
Therefore, the times of returning for every customer will be calculated accurately.
*/

/*Diccussion about Normalization
I applied database normalization. There's no duplicated column. For every primary key, every non-attribute key is fully dependent on the 
primary key. All non-attribute keys in the tables are mutually independent. In the tables that 
I created, each entity is represented by a single relation.

Normalization helps reduce duplicated information, which avoids possible inconsistencies 
where duplicated copies value diverge in value and eliminates the expense of maintaining
duplicated information. 
*/



----------------------Testing------------------------------------

INSERT INTO [dbo].[merchandise]
           ([merchandiseId]
           ,[merchandiseName]
           ,[merchandiseType]
           ,[price])
     VALUES
           ('A77615', 'Jeans', 'Man', 80) 

INSERT INTO customer (customerId, customerName, street, city, postalCode, email)
VALUES ('1004', 'Viky Swana', '880 Alberta St','Waterloo', 'N2L8P2', 'Vikkk@gmail.com')

INSERT INTO returned_merchandise (merchandiseId, customerId, reasonForReturn)
VALUES ('A28712', '1002', 'The customer thinks the skirt is too short.')

select * from merchandise
select * from customer
select * from returned_merchandise




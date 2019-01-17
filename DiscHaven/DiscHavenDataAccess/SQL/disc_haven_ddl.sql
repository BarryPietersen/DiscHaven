/*
	Developed By: Barry Pietersen, Z018771
	Purpose: DDL Script for the Disc Haven database
	Date Created: 03/08/2018
*/

USE master;
GO

DROP DATABASE IF EXISTS db_disc_haven;
GO

CREATE DATABASE db_disc_haven;
GO

USE db_disc_haven;
GO

------------------------------ ENCRYPTION / DECRYPTION ------------------------------
--------------------- MASTER KEYS, CERTIFICATES, SYMMETRIC KEYS ---------------------
--
-- https://support.microsoft.com/en-au/help/246071/description-of-symmetric-and-asymmetric-encryption
--
-- https://docs.microsoft.com/en-us/sql/t-sql/statements/create-master-key-transact-sql
--
-- The database master key is a symmetric key used to protect the private keys of certificates and 
-- asymmetric keys that are present in the database. When it is created, the master key is encrypted 
-- by using the AES_256 algorithm and a user-supplied password...
-- To enable the automatic decryption of the master key, a copy of the key is encrypted by using the
-- service master key and stored in both the database and in master...


-- Create a Database Master Key & Certificate to protect the symmetric key store...
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '19640523DiscHaven';	-- dream up a strong password

CREATE CERTIFICATE DiscHaven_Certificate WITH SUBJECT = 'Disc Haven Security Certificate';



-- Create a symmetric key encrypted using this certificate...
CREATE SYMMETRIC KEY DiscHaven_SymmetricKey WITH
	IDENTITY_VALUE = 'DiscHaven_SpecialKey',			-- dream up a secure name
	ALGORITHM = AES_256,							-- robust 256-bit encryption algorithm
	KEY_SOURCE = '45#$To345B&&4 HHt3_eR34@3'		-- dream up a very strong passphrase
	ENCRYPTION BY CERTIFICATE DiscHaven_Certificate;		-- certificate name must match the one created above
GO

-- determine if the product of quantity and price
-- will result in an overflow of 'smallmoney' datatype,
-- used as part of a check constraint in both cart and orderline tables
CREATE FUNCTION usfCheckLineTotalOverflow
(
	@Quantitiy	INTEGER,
	@ItemPrice	SMALLMONEY
)
	RETURNS BIT
AS
BEGIN
	-- max value of smallmoney
	IF (214748.364 / @ItemPrice < @Quantitiy)
		RETURN 1;

	RETURN 0;
END
GO

-- in support of tblcart linetotal constraint,
-- used to pass the price of the product into
-- usfCheckLineTotalOverflow function
CREATE FUNCTION usfPriceByID
(
	@ID	BIGINT
)
	RETURNS SMALLMONEY
AS
BEGIN
	DECLARE @Price SMALLMONEY
	SET @Price = (SELECT P.Price FROM tblProduct P WHERE P.ID = @ID)
	RETURN @Price
END
GO

----tblBranch-------------------------------------------
CREATE TABLE tblLocation
(
	[ID]			BIGINT PRIMARY KEY IDENTITY,
	[Description]	NVARCHAR(max)	NOT NULL,
	[Address]		NVARCHAR(250)	NOT NULL,
	[PhoneNumber]	NVARCHAR(250)	NOT NULL,
	[Email]			NVARCHAR(250)	NOT NULL,
	[City]			NVARCHAR(250)	NOT NULL,
	[State]			NVARCHAR(250)	NOT NULL,
	[PostCode]		VARCHAR(10)		NOT NULL,	
);

----tblStaff-------------------------------------------------
CREATE TABLE tblStaff
(
	[ID]			BIGINT PRIMARY KEY IDENTITY,
	[FKLocationID]	BIGINT				NOT NULL,
	[FirstName]		NVARCHAR(250)		NOT NULL,
	[LastName]		NVARCHAR(250)		NOT NULL,
	[Email]			NVARCHAR(250)		NOT NULL,
	[Address]		NVARCHAR(250)		NOT NULL,
	[City]			NVARCHAR(250)		NOT NULL,
	[State]			NVARCHAR(250)		NOT NULL,
	[PostCode]		VARCHAR(10)			NOT NULL,
	[DOB]			DATE				NOT NULL,
	[PhoneNumber]	NVARCHAR(250)		NOT NULL,
	[Comments]		NVARCHAR(MAX)		NOT NULL,
	[Image]			NVARCHAR(250)		NOT NULL,	
	[Username]		NVARCHAR(250)		NOT NULL UNIQUE,
	[PasswordHash]	BINARY(64)			NOT NULL,
	[PasswordHint]	VARBINARY(256)		NOT NULL,
	[Salt]			UNIQUEIDENTIFIER	NOT NULL,
	[IsActive]		BIT					NOT NULL,
);
CREATE INDEX idxUsername ON tblStaff([Username]);

----tblRole-------------------------------------------
CREATE TABLE tblRole
(
	[ID]		BIGINT PRIMARY KEY IDENTITY,
	[Ranking]	INT NOT NULL,
	[Name]		VARCHAR(250)
);

----tblStaffRole-------------------------------------------
CREATE TABLE tblStaffRole
(
	[ID]			BIGINT PRIMARY KEY IDENTITY,
	[FKStaffID]		BIGINT		NOT NULL,
	[FKRoleID]		BIGINT		NOT NULL,			

	FOREIGN KEY ([FKStaffID])	REFERENCES tblStaff([ID]),
	FOREIGN KEY ([FKRoleID])	REFERENCES tblRole([ID])
);
CREATE UNIQUE INDEX idxStaffIDRoleID ON tblStaffRole([FKStaffID], [FKRoleID]);
CREATE INDEX idxRoleID ON tblStaffRole([FKRoleID]);

----tblCustomer-------------------------------------------------
CREATE TABLE tblCustomer
(
	[ID]			BIGINT PRIMARY KEY IDENTITY,
	[FirstName]		NVARCHAR(250)		NOT NULL,
	[LastName]		NVARCHAR(250)		NOT NULL,
	[Email]			NVARCHAR(250)		NOT NULL,
	[Address]		NVARCHAR(250)		NOT NULL,
	[City]			NVARCHAR(250)		NOT NULL,
	[State]			NVARCHAR(250)		NOT NULL,
	[PostCode]		NVARCHAR(10)		NOT NULL,
	[ShipAddress]	NVARCHAR(250)		NOT NULL,
	[ShipCity]		NVARCHAR(250)		NOT NULL,
	[ShipState]		NVARCHAR(250)		NOT NULL,
	[ShipPostCode]	NVARCHAR(10)		NOT NULL,
	[Username]		NVARCHAR(250)		NOT NULL UNIQUE,
	[PasswordHash]	BINARY(64)			NOT NULL,
	[PasswordHint]	VARBINARY(128)		NOT NULL,
	[Salt]			UNIQUEIDENTIFIER	NOT NULL
);
CREATE INDEX idxUsername ON tblCustomer(Username);

----tblSecurityQuestion-------------------------------------------------
CREATE TABLE tblSecurityQuestion
(
	[ID]			BIGINT PRIMARY KEY IDENTITY,
	[FKCustomerID]	BIGINT				NOT NULL,
	[Question]		VARBINARY(256)		NOT NULL,
	[Answer]		BINARY(64)			NOT NULL,
	[AnswerSalt]	UNIQUEIDENTIFIER	NOT NULL,

	FOREIGN KEY ([FKCustomerID])	REFERENCES tblCustomer([ID])
)
CREATE INDEX idxCustomerID ON tblSecurityQuestion(FKCustomerID);

----tblSearch-------------------------------------------------
CREATE TABLE tblSearch
(
	[ID]				BIGINT PRIMARY KEY IDENTITY,
	[FKCustomerID]		BIGINT			NOT NULL,
	[DateTime]			DATETIME2		NOT NULL,
	[Description]		NVARCHAR(250)	NOT NULL,

	FOREIGN KEY ([FKCustomerID])	REFERENCES tblCustomer([ID])
);
CREATE INDEX idxCustomerID ON tblSearch(FKCustomerID);

----tblMediaType-------------------------------------------------
CREATE TABLE tblMediaType
(
	[ID]			BIGINT PRIMARY KEY IDENTITY,
	[Description]	NVARCHAR(250) NOT NULL UNIQUE,
);

----tblCategory-------------------------------------------------
CREATE TABLE tblCategory
(
	[ID]			BIGINT PRIMARY KEY IDENTITY,
	[Description]	NVARCHAR(250) NOT NULL UNIQUE,
);

----tblTitle-------------------------------------------------
CREATE TABLE tblTitle
(
	[ID]			BIGINT PRIMARY KEY IDENTITY,
	[FKCategoryID] 	BIGINT			NOT NULL,
	[Name]			NVARCHAR(250)	NOT NULL,
	[Description]	NVARCHAR(MAX)	NOT NULL,

	FOREIGN KEY ([FKCategoryID])	REFERENCES tblCategory([ID])
);
CREATE UNIQUE INDEX idxTitleCategory ON tblTitle([Name], FKCategoryID);
CREATE INDEX idxCategoryID ON tblTitle([FKCategoryID]);

----tblProduct-------------------------------------------------
CREATE TABLE tblProduct
(
	[ID]				BIGINT			PRIMARY KEY IDENTITY,
	[FKTitleID]			BIGINT			NOT NUll,
	[FKMediaTypeID]		BIGINT			NOT NULL,
	[Name]				NVARCHAR(250)	NOT NULL,
	[Description]		NVARCHAR(MAX)	NOT NULL,
	[RRP]				SMALLMONEY		NOT NULL CHECK(RRP >= 0) DEFAULT 0,
	[DiscountFactor]	FLOAT			NOT NULL CHECK(DiscountFactor >= 0 AND DiscountFactor <= 1),
	[Discount]			AS([RRP] * [DiscountFactor]),
	[Price]				AS([RRP] * (1 - [DiscountFactor])),
	[RelDate]			DATETIME2		NOT NULL,
	[IsActive]			BIT				NOT NULL DEFAULT 'TRUE',
	[DateDeactivated]	DATE			NULL,
	[Image]				VARCHAR(250)	NOT NULL,

	FOREIGN KEY ([FKTitleID])		REFERENCES tblTitle([ID]),
	FOREIGN KEY ([FKMediaTypeID])	REFERENCES tblMediaType([ID])
	--CONSTRAINT unqTitleMediaName	UNIQUE NONCLUSTERED
	--(
	--   [FKTitleID], [FKMediaTypeID], [Name]
	--)
);
CREATE UNIQUE INDEX idxTitleNameMediaType ON tblProduct([Name], [FKTitleID], [FKMediaTypeID]);
CREATE INDEX idxTitleID ON tblProduct([FKTitleID]);
CREATE INDEX idxFKMediaTypeID ON tblProduct([FKMediaTypeID]);

----tblLocationStock-------------------------------------------
CREATE TABLE tblLocationStock
(
	[ID]			BIGINT PRIMARY KEY IDENTITY,
	[FKLocationID]	BIGINT	NOT NULL,
	[FKProductID]	BIGINT	NOT NULL,		
	[Quantity]		BIGINT	NOT NULL

	FOREIGN KEY ([FKLocationID])	REFERENCES tblLocation([ID]),
	FOREIGN KEY ([FKProductID])		REFERENCES tblProduct([ID])
);
CREATE INDEX idxLocationID ON tblLocationStock([FKLocationID]);
CREATE INDEX idxProductID ON tblLocationStock([FKProductID]);

----tblCart-------------------------------------------
CREATE TABLE tblCart
(
	[ID]			BIGINT PRIMARY KEY IDENTITY,
	[FKCustomerID]	BIGINT  NOT NULL,
	[FKProductID]	BIGINT  NOT NULL,
	[Quantity]		INTEGER NOT NULL,
	[DateAdded]		Date	NOT NULL,

	FOREIGN KEY (FKCustomerID) REFERENCES tblCustomer(ID),
	FOREIGN KEY (FKProductID)  REFERENCES tblProduct(ID),

	CONSTRAINT chkCartLineTotalOverflow CHECK (dbo.usfCheckLineTotalOverflow(Quantity, dbo.usfPriceByID(FKProductID)) = 0)
);
--CREATE INDEX idxCustomerID ON tblCart(FKCustomerID);
CREATE UNIQUE INDEX idxCustProd ON tblCart(FKCustomerID, FKProductID)
CREATE INDEX idxProductID ON tblCart(FKProductID);

----tblConfiguration-------------------------------------------
CREATE TABLE tblConfiguration
(
	[ID]					BIGINT	PRIMARY KEY IDENTITY,
	[NumPageItemsToDisplay]	INTEGER	NOT NULL,
	[SlideShowDelaySec]		FLOAT	NOT NULL,
	[GST]					FLOAT	NOT NULL,
	[GSTFactor]				AS(GST / 100)
);

----tblOrderStatus-------------------------------------------
CREATE TABLE tblOrderStatus
(
	[ID]			BIGINT PRIMARY KEY IDENTITY,
	[StatusCode]	INTEGER NOT NULL,
)

----tblOrder-------------------------------------------
CREATE TABLE tblOrder
(
	[ID]					BIGINT PRIMARY KEY IDENTITY,
	[FKCustomerID]			BIGINT	NOT NULL,
	[FKLocationID]			BIGINT	NOT NULL,
	[FKStatusID]			BIGINT	NOT NULL,
	[DateTime]				DATE	NOT NULL,
	[GST]					FLOAT	NOT NULL,
	[UseShippingAddress]	BIT		NOT NULL,

	FOREIGN KEY ([FKLocationID])	REFERENCES tblLocation([ID]),
	FOREIGN KEY ([FKCustomerID])	REFERENCES tblCustomer([ID]),
	FOREIGN KEY ([FKStatusID])		REFERENCES tblOrderStatus([ID])
);
CREATE INDEX idxCustomerID ON tblOrder([FKCustomerID]);
CREATE INDEX idxLocationID ON tblOrder([FKLocationID]);
CREATE INDEX idxStatusID ON tblOrder([FKStatusID]);

----tblOrderLine-------------------------------------------
CREATE TABLE tblOrderLine
(
	[ID]			BIGINT PRIMARY KEY IDENTITY,
	[FKOrderID]		BIGINT			NOT NULL,
	[FKProductID]	BIGINT			NOT NULL,
	[Name]			NVARCHAR(250)	NOT NULL,				
	[Quantity]		INTEGER			NOT NULL,
	[ItemPrice]		SMALLMONEY		NOT NULL,
	[LineTotal]		AS([ItemPrice] * [Quantity]),

	FOREIGN KEY ([FKOrderID])	REFERENCES tblOrder([ID]),
	FOREIGN KEY ([FKProductID])	REFERENCES tblProduct([ID]),

	CONSTRAINT chkOrderLineTotalOverflow CHECK (dbo.usfCheckLineTotalOverflow(Quantity, ItemPrice) = 0)
);
CREATE INDEX idxOrderID ON tblOrderLine([FKOrderID]);
CREATE INDEX idxProductID ON tblOrderLine(FKProductID);

USE master;
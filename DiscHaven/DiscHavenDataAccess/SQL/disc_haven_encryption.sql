/*
Date: 18/11/2017
Last Update: 31/8/2018
Author: Ramin Majidi
Purpose: Database schema security script DDL for encryption and decryption.
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

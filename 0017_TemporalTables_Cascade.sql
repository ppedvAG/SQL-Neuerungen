USE Master;

DROP DATABASE if exists TemporalDB;
GO

CREATE DATABASE [TemporalTables]
GO

USE [TemporalTables]
GO

-- Create temporal table -- CustomerName column is unique here.
CREATE TABLE dbo.Customer 
(  
  CustomerId INT IDENTITY(1,1) NOT NULL ,
  CustomerName VARCHAR(100) NOT NULL PRIMARY KEY CLUSTERED, 
  StartDate DATETIME2 GENERATED ALWAYS AS ROW START  NOT NULL,
  EndDate   DATETIME2 GENERATED ALWAYS AS ROW END  NOT NULL,
  PERIOD FOR SYSTEM_TIME (StartDate, EndDate)   
) 
WITH(SYSTEM_VERSIONING= ON (HISTORY_TABLE=dbo.CustomerHistory ) )
GO

-- insert into customer table
INSERT INTO dbo.Customer   (   CustomerName)                   
                     (SELECT  'Sam Union')
               UNION (SELECT  'Fred Dillard')
               UNION (SELECT  'Marry Gordan')
               UNION (SELECT  'Seth Molin')
               UNION (SELECT  'Brian Shah')
               UNION (SELECT  'Lauren Ziller')
GO                

-- Create normal table with relationship with temporal table
CREATE TABLE dbo.CustomerDetail 
(
   CustomerDetailId int
   ,CustomerName VARCHAR(100) CONSTRAINT FK_CustomerDetail_CustomerName FOREIGN KEY REFERENCES dbo.Customer(CustomerName) 
			ON UPDATE CASCADE
			ON DELETE CASCADE
   ,Customer_DOB Date 
   ,Customer_Address varchar(50)
)
GO

-- insert into cusomerDetail table
INSERT INTO dbo.CustomerDetail   (CustomerDetailId, CustomerName, Customer_DOB, Customer_Address)   
                  (SELECT  101,      'Brian Shah', '30.09.1971', '101 Street 1, IL' )
            UNION (SELECT  102,   'Fred Dillard', '30.10.1972', '202 Street 2, IL' )
            UNION (SELECT  103,   'Lauren Ziller', '30.11.1973', '303 Street 3, IL' )
            UNION (SELECT  104,   'Marry Gordan', '30.12.1974', '404 Street 4, IL' )
            UNION (SELECT  105,   'Sam Union', '30.01.1975', '505 Street 5, IL' )
            UNION (SELECT  106,   'Seth Molin', '30.03.1976', '606 Street 6, IL' )
GO

-- Check the data in 3 tables.
SELECT * FROM dbo.Customer
SELECT * FROM dbo.CustomerHistory
SELECT * FROM dbo.CustomerDetail
GO

--�ndern
DELETE FROM Customer WHERE CustomerName = 'Fred Dillard'
GO

-- Check the data in 3 tables.

SELECT * FROM dbo.Customer
SELECT * FROM dbo.CustomerHistory
SELECT * FROM dbo.CustomerDetail
GO

Update Customer
set CustomerName = 'Sam Henry' where CustomerName = 'Sam Union'

-- Check the data in 3 tables.
SELECT * FROM dbo.Customer
SELECT * FROM dbo.CustomerHistory
SELECT * FROM dbo.CustomerDetail
GO
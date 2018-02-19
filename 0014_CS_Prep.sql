--REAL TIME:
--https://docs.microsoft.com/de-de/sql/relational-databases/indexes/get-started-with-columnstore-for-real-time-operational-analytics


Use northwind;

SELECT     Customers.CompanyName, Customers.CustomerID, Customers.City, Customers.Country, Orders.OrderID, Orders.OrderDate, Orders.Freight, Orders.ShipCity, Orders.ShipCountry, [Order Details].UnitPrice, [Order Details].Quantity, [Order Details].ProductID, 
                  Products.ProductName, Employees.EmployeeID, Employees.LastName, Employees.FirstName, Employees.City AS Expr1, Employees.Country AS Expr2
INTO umsatzxy
FROM        Customers INNER JOIN
                  Orders ON Customers.CustomerID = Orders.CustomerID INNER JOIN
                  [Order Details] ON Orders.OrderID = [Order Details].OrderID INNER JOIN
                  Products ON [Order Details].ProductID = Products.ProductID INNER JOIN
                  Employees ON Orders.EmployeeID = Employees.EmployeeID
go

insert into umsatzxy
select top 100000 * from umsatzxy
GO 

alter table umsatzxy
add UmsatzID int identity
GO

select top 5 * from umsatzxy

--ColumnStore

--ca 570MB mit ca. 2,2 Mio Zeilen

--Kopie
select * into Umsatzxy2 from umsatzxy


USE [Northwind]
GO

/****** Object:  Index [GRCSIX]    Script Date: 04.08.2016 14:27:21 ******/
CREATE CLUSTERED COLUMNSTORE INDEX
 [GRCSIX] ON [dbo].[umsatzxy]
  WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0) ON [PRIMARY]
GO
--Die Kopie mit Zeilendaten hääte bei Kompression ca 170MB

--Die CS Tabelle hat nur nch 7 MB ca

USE [Northwind]
ALTER TABLE [dbo].[umsatzxy] REBUILD PARTITION = ALL
WITH 
(DATA_COMPRESSION = COLUMNSTORE_ARCHIVE
)

set statistics io, time on
Select city , companyname, avg(quantity)
from	umsatzxy
where	productid between 20 and 25
group by city, companyname


Select city , companyname, avg(quantity)
from	umsatzxy2
where	productid between 20 and 25
group by city, companyname


--Schatten??

--INS DEL UP
--delta store.. normale Seiten
--bei ca 1 Mio.. Tuple Mover... en masse komprimiert in Segemente 
--BULK mit ca 140000 ..direkt in Segmente komprimiert

select * from sys.dm_db_column_store_row_group_physical_stats


--nach Archivierungskompression ca 6,8
--Messung der CPU, Dauer und HDD Zugriff
set statistics io on
set statistics time on


select top 3 * from umsatzxy

select country, sum(freight) from umsatzxy
where country ='Germany'
group by country


select country, sum(freight) from umsatzxy2
where country ='Germany'
group by country
--70195 Lesen
--CPU-Zeit = 938 ms, verstrichene Zeit = 249 ms.




insert into umsatzxy
SELECT top 200000 [CompanyName]
      ,[CustomerID]
      ,[City]
      ,[Country]
      ,[OrderID]
      ,[OrderDate]
      ,[Freight]
      ,[ShipCity]
      ,[ShipCountry]
      ,[UnitPrice]
      ,[Quantity]
      ,[ProductID]
      ,[ProductName]
      ,[EmployeeID]
      ,[LastName]
      ,[FirstName]
      ,[Expr1]
      ,[Expr2]
     
  FROM [dbo].[umsatzxy]

  --löschen von daten
  delete from umsatzxy where umsatzid < 10000

  --keine Datenlöschung , nur als gelöscht markiert
  --update: INS + DEL
use nwindbig


--Paralell.. wiviele CPUs verwendet er: 
--per default: alle!
--oder einen!
select companyname, orderid from customers c inner join orders o 
on c.customerid = o.customerid where orderid < 100000

set statistics time on

--ale CPUs für einen Abfrage machen kaum Sinn
--Bsp: 1000 Maler für einen Raum
--OLTP: 25 Kosten 4 bis 8 CPUs
--OLAP: 50
EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'cost threshold for parallelism', N'25'
GO
EXEC sys.sp_configure N'max degree of parallelism', N'4'
GO
RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'show advanced options', N'0'  RECONFIGURE WITH OVERRIDE
GO


--theoretisch auch für DB einstellbar (ab 2016)
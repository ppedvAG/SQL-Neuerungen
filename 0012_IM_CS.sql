USE CS;
GO

Drop table if exists orders
Drop table if exists orderscsim

create table orders (
AccountKey int not null,
customername nvarchar (50),
OrderNumber bigint,
PurchasePrice decimal (9,2),
OrderStatus smallint not NULL,
OrderStatusDesc nvarchar (50))

-- OrderStatusDesc
-- 0 => 'Order Started'
-- 1 => 'Order Closed'
-- 2 => 'Order Paid'
-- 3 => 'Order Fullfillment Wait'
-- 4 => 'Order Shipped'
-- 5 => 'Order Received'

set nocount on

create clustered index orders_ci on orders(OrderStatus)

--Now we load 3 million rows with the data pattern that 95% of the orders have already been received by the customer.

-- insert into the main table load 3 million rows
declare @outerloop int = 0
declare @i int = 0
declare @purchaseprice decimal (9,2)
declare @customername nvarchar (50)
declare @accountkey int
declare @orderstatus smallint
declare @orderstatusdesc nvarchar(50)
declare @ordernumber bigint
while (@outerloop < 3000000)
begin
Select @i = 0
begin tran
while (@i < 2000)
begin
set @ordernumber = @outerloop + @i
set @purchaseprice = rand() * 1000.0
set @accountkey = convert (int, RAND ()*1000)
set @orderstatus = convert (smallint, RAND()*100)
if (@orderstatus >= 5) set @orderstatus = 5

set @orderstatusdesc  =
case @orderstatus
WHEN 0 THEN  'Order Started'
WHEN 1 THEN  'Order Closed'
WHEN 2 THEN  'Order Paid'
WHEN 3 THEN 'Order Fullfillment'
WHEN 4 THEN  'Order Shipped'
WHEN 5 THEN 'Order Received'
END
insert orders values (@accountkey,
(convert(varchar(6), @accountkey) + 'firstname'),@ordernumber, @purchaseprice,@orderstatus, @orderstatusdesc)

set @i += 1;
end
commit

set @outerloop = @outerloop + 2000
set @i = 0
end
go



--Now we load 3 million rows with the data pattern that 95% of the orders have already been received by the customer.

-- insert into the main table load 3 million rows
declare @outerloop int = 0
declare @i int = 0
declare @purchaseprice decimal (9,2)
declare @customername nvarchar (50)
declare @accountkey int
declare @orderstatus smallint
declare @orderstatusdesc nvarchar(50)
declare @ordernumber bigint
while (@outerloop < 3000000)
begin
Select @i = 0
begin tran
while (@i < 2000)
begin
set @ordernumber = @outerloop + @i
set @purchaseprice = rand() * 1000.0
set @accountkey = convert (int, RAND ()*1000)
set @orderstatus = convert (smallint, RAND()*100)
if (@orderstatus >= 5) set @orderstatus = 5

set @orderstatusdesc  =
case @orderstatus
WHEN 0 THEN  'Order Started'
WHEN 1 THEN  'Order Closed'
WHEN 2 THEN  'Order Paid'
WHEN 3 THEN 'Order Fullfillment'
WHEN 4 THEN  'Order Shipped'
WHEN 5 THEN 'Order Received'
END
insert orders values (@accountkey,
(convert(varchar(6), @accountkey) + 'firstname'),@ordernumber, @purchaseprice,@orderstatus, @orderstatusdesc)

set @i += 1;
end
commit

set @outerloop = @outerloop + 2000
set @i = 0
end
go


--create NCCI
CREATE NONCLUSTERED COLUMNSTORE INDEX orders_ncci ON orders  (accountkey, customername, purchaseprice, orderstatus, orderstatusdesc)

CREATE NONCLUSTERED  INDEX orders_nc ON orders(accountkey) include ( customername, purchaseprice, orderstatus, orderstatusdesc)

--insert additional 200k rows
declare @outerloop int = 3000000
declare @i int = 0
declare @purchaseprice decimal (9,2)
declare @customername nvarchar (50)
declare @accountkey int
declare @orderstatus smallint
declare @orderstatusdesc nvarchar(50)
declare @ordernumber bigint
while (@outerloop < 3200000)
begin
Select @i = 0
begin tran
while (@i < 2000)
begin
set @ordernumber = @outerloop + @i
set @purchaseprice = rand() * 1000.0
set @accountkey = convert (int, RAND ()*1000)
set @orderstatus = convert (smallint, RAND()*5)
set @orderstatusdesc =
case @orderstatus
WHEN 0 THEN 'Order Started'
WHEN 1 THEN 'Order Closed'
WHEN 2 THEN 'Order Paid'
WHEN 3 THEN 'Order Fullfillment'
WHEN 4 THEN 'Order Shipped'
WHEN 5 THEN 'Order Received'
END
insert orders values (@accountkey,(convert(varchar(6), @accountkey) + 'firstname'),
@ordernumber, @purchaseprice, @orderstatus, @orderstatusdesc)
set @i += 1;
end
commit
set @outerloop = @outerloop + 2000
set @i = 0
end
go

set statistics io, time off
--TEST 1
select max (PurchasePrice)
from orders

select max (PurchasePrice)
from orders
option (IGNORE_NONCLUSTERED_COLUMNSTORE_INDEX)

--TEST 2

-- a more complex query
select top 5 customername, sum (PurchasePrice), Avg (PurchasePrice)
from orders
where purchaseprice > 90.0 and OrderStatus=5
group by customername

select top 5 customername, sum (PurchasePrice), Avg (PurchasePrice)
from orders
where purchaseprice > 90.0 and OrderStatus = 5
group by customername
option (IGNORE_NONCLUSTERED_COLUMNSTORE_INDEX)


--------------------------------------------------------------
---MIT IM-----------------------------------------------------
--------------------------------------------------------------
USE [CS]
GO


CREATE TABLE [dbo].[orderscsim]
(
	[ID] int identity ,
	[AccountKey] [int] NOT NULL,
	[customername] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[OrderNumber] [bigint] NULL,
	[PurchasePrice] [decimal](9, 2) NULL,
	[OrderStatus] [smallint] NOT NULL,
	[OrderStatusDesc] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,

 PRIMARY KEY NONCLUSTERED HASH 
(
	[id]
)WITH ( BUCKET_COUNT = 1048576)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_AND_DATA )
GO

--CS ColumnstoreIX auf IM
Alter table [orderscsim]  add index IX_CS clustered columnstore

--INSERT 3 MIO
declare @outerloop int = 0
declare @i int = 0
declare @purchaseprice decimal (9,2)
declare @customername nvarchar (50)
declare @accountkey int
declare @orderstatus smallint
declare @orderstatusdesc nvarchar(50)
declare @ordernumber bigint
while (@outerloop < 3000000)
begin
Select @i = 0
begin tran
while (@i < 2000)
begin
set @ordernumber = @outerloop + @i
set @purchaseprice = rand() * 1000.0
set @accountkey = convert (int, RAND ()*1000)
set @orderstatus = convert (smallint, RAND()*100)
if (@orderstatus >= 5) set @orderstatus = 5

set @orderstatusdesc  =
case @orderstatus
WHEN 0 THEN  'Order Started'
WHEN 1 THEN  'Order Closed'
WHEN 2 THEN  'Order Paid'
WHEN 3 THEN 'Order Fullfillment'
WHEN 4 THEN  'Order Shipped'
WHEN 5 THEN 'Order Received'
END
insert [orderscsim] values (@accountkey,
(convert(varchar(6), @accountkey) + 'firstname'),@ordernumber, @purchaseprice,@orderstatus, @orderstatusdesc)

set @i += 1;
end
commit

set @outerloop = @outerloop + 2000
set @i = 0
end
go

CREATE NONCLUSTERED COLUMNSTORE INDEX 
	orders_ncciIM ON orderscsim  (accountkey, customername, purchaseprice, orderstatus, orderstatusdesc)

CREATE NONCLUSTERED  INDEX 
	orders_ncIM ON orderscsim(accountkey) include ( customername, purchaseprice, orderstatus, orderstatusdesc)



 Alter table [orderscsim]  add index IXCS clustered columnstore


 ALTER TABLE [dbo].[orderscsim]
	ADD INDEX IXNCAccount NONCLUSTERED (accountkey)
GO

ALTER TABLE [dbo].[orderscsim]
	ADD INDEX  orders_ncIM  (accountkey) 
			


declare @outerloop int = 3000000
declare @i int = 0
declare @purchaseprice decimal (9,2)
declare @customername nvarchar (50)
declare @accountkey int
declare @orderstatus smallint
declare @orderstatusdesc nvarchar(50)
declare @ordernumber bigint
while (@outerloop < 3200000)
begin
Select @i = 0
begin tran
while (@i < 2000)
begin
set @ordernumber = @outerloop + @i
set @purchaseprice = rand() * 1000.0
set @accountkey = convert (int, RAND ()*1000)
set @orderstatus = convert (smallint, RAND()*5)
set @orderstatusdesc =
case @orderstatus
WHEN 0 THEN 'Order Started'
WHEN 1 THEN 'Order Closed'
WHEN 2 THEN 'Order Paid'
WHEN 3 THEN 'Order Fullfillment'
WHEN 4 THEN 'Order Shipped'
WHEN 5 THEN 'Order Received'
END
insert orderscsim values (@accountkey,(convert(varchar(6), @accountkey) + 'firstname'),
@ordernumber, @purchaseprice, @orderstatus, @orderstatusdesc)
set @i += 1;
end
commit
set @outerloop = @outerloop + 2000
set @i = 0
end
go


set statistics io, time on

--TEST 1
select max (PurchasePrice)
from orderscsim

select max (PurchasePrice)
from orderscsim
option (IGNORE_NONCLUSTERED_COLUMNSTORE_INDEX)

--TEST 2

-- a more complex query
select top 5 customername, sum (PurchasePrice), Avg (PurchasePrice)
from orderscsim
where purchaseprice > 90.0 and OrderStatus=5
group by customername

select top 5 customername, sum (PurchasePrice), Avg (PurchasePrice)
from orderscsim
where purchaseprice > 90.0 and OrderStatus = 5
group by customername
option (IGNORE_NONCLUSTERED_COLUMNSTORE_INDEX)


use TemporalTables
GO

insert into Contacts 
(Lastname,Firstname,Birthday, Phone, email) 
select 'Kent', 'Clark','3.4.2010', '089-3303003', 'clarkk@krypton.universe' 

insert into Contacts 
(Lastname,Firstname,Birthday, Phone, email) 
select 'Wayne', 'Bruce','3.4.2012', '08677-3303003', 'brucew@gotham.city' 

--Und nun die Änderungen, die zu einer Versionierung der Datensätze führt 
WAITFOR DELAY '00:00:02'
update contacts set email = 'wer@earth.de' where cid = 1 
update contacts set Phone = 'w3434' where cid = 1 
update contacts set Lastname = 'Wayne' where cid = 1 

WAITFOR DELAY '00:00:02'

update contacts set email = 'asas@earth.de' where cid = 1 
update contacts set Phone = 'w34sasaa34' where cid = 2 
update contacts set Lastname = 'Smith' where cid = 1 

--Result
select * from contacts 
select * from ContactsHistory 


--nach Version suchen

select * from contactshistory 
where 
    Startdatum >= '2018-02-01 10:35:12' 
    and 
    Enddatum <= '2018-02-01 10:35:13'  

--Noch besser
select * from contacts 
    FOR SYSTEM_TIME AS OF '2018-02-01 10:35:13' 
    where cid =1 


	--Was wenn..
Alter Table contacts
	add spx int


update contacts set Firstname= 'Chris', spx=2 where cid = 1
select * from contacts 
    FOR SYSTEM_TIME AS OF '2018-02-01 10:35:13' 
    where cid =1 

--nope
delete from Contactshistory where StartDatum <= '2018-02-01 10:35:13'



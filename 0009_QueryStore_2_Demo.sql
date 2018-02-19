---Planverhalten:

--SEEK (CL IX Seek, NON CL. IX SEEK)
--SCAN (Table Scan, CL IX SCAN, NON CL IX SCAN)

--ohne where immer Scan!
--SCAN --> A bis Z
--SEEK herauspicken

--Prozeduren: Warum gelten PROC als besser?
--kompiliert (nur der Plan)


--im tats. Plan ein @1
select * from person.person where firstname = 'Ken'

--bei Proz wird der Plan fest hinterlegt (auch nach Neustart)
--wann wird der PLan fest hinterlegt:
-----> bei der ersten Ausführung


create procedure gpPersonSuche @Vorname varchar(50)
as
select * from person.person where firstname like @vorname +'%';
GO

set statistics io, time on

dbcc showcontig ('person.person') --....: 3809
exec gpPersonsuche '%'
dbcc freeproccache
exec gpPersonsuche 'Aa'

--Proc ist nur dann gut, wenn nicht benutzerfreunndlich!
--immer gleich viel oder wenige..!!
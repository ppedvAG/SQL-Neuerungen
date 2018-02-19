---Prinzip:
--Backup Restore auf anderen Server: Logins?, Jobs?

--ContainedDatabase:
--Login an der DB (nicht an master)
--#tabelle bekommen Sortierung der OrgDB nicht der tempdb
--auf Server aktivieren
EXEC sys.sp_configure N'contained database authentication', N'1'
GO
RECONFIGURE WITH OVERRIDE
GO
USE [master]
GO
ALTER DATABASE [ContDB] SET CONTAINMENT = PARTIAL WITH NO_WAIT
GO


USE [ContDB]
GO
CREATE USER [Dirk] WITH PASSWORD=N'ppedvAG01!'
GO


alter database contdb set trustworthy on


alter database contdb set trustworthy on


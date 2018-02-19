--Der Wartungsplan ist für Backup absolut ok!
--Für Wartung von DB (IX+Statistiken) grottenschlecht..bis 2016

--IX
--Fragmentierung von IX
--unter 10% Fragm.. nix
--über 30% ..Rebuild
--dazwischen --Reorg

--IX+Statistikenaktualisierungen

--wann aktualisert er...
--20% Änderungen +500
--1 MIO Zeilen, dann 200000 Ins--> keine Aktualisierung

use adventureworks2014

select * into person.person2 from person.person

select * from person.person2 where firstname = 'ken'

--NON CL... Super bei Abfragen, bei denen rel wenig rauskommt
--NON CL ...ist mies wenn viele rauskommen
--CL IX-- ist auch gut bei vielen Datensätzen im Ergebnis

--NCL ist gut bei = , oder IDs
--CL IX super bei Abfrage auf Wertebereiche  (Datum von  bis)

--CL IX gibts nur einmal und ist die Tabelle
--Stat wir gemacht bei IX Erstellung
--oder bei Where Spalten, die keinen IX haben.. Stichproben

--Idee kommt rel wenig raus, dann lohnt sich der NON CL IX SEEK
--sonst besser SCAN


select * from sys.dm_db_index_usage_stats

Ola Hallengren -- Maintenance Solution.sql

--besser wg. % Fragemntierung, Anzahl der Seiten
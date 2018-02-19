--AB SQL 2017--Retention
CREATE TABLE TestTemporal(
Id INT CONSTRAINT PK_ID PRIMARY KEY,
CustomerName VARCHAR(50),
StartDate DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL, 
EndDate DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,
PERIOD FOR SYSTEM_TIME (StartDate, EndDate)
)
WITH (SYSTEM_VERSIONING = ON 
         (HISTORY_TABLE = dbo.TestTemporalHistory, 
            History_retention_period = 2 DAYS --Days, Week, Month, Year --  <-----
          )
      ) 
GO

SELECT is_temporal_history_retention_enabled, NAME FROM sys.databases
GO;
--Row
create user Chef without login
create user AbtLeiter without Login
create user Manager without Login


CREATE TABLE [dbo].[Employees]
(
  [ID] [int] PRIMARY KEY CLUSTERED IDENTITY(1,1) NOT NULL,
  [Name] [varchar](100) NULL,
  [Address] [varchar](256) NULL,
  [Email] [varchar](256) NULL,
  [Salary] [decimal](18,2) NOT NULL,
  [SecColFilter] [varchar](128) NULL
);


INSERT INTO [dbo].[Employees]
           ([Name]
           ,[Address]
           ,[Email]
           ,[Salary]
           ,[SecColFilter])
     VALUES
        ('Rauch'           ,'BGH'           ,'andreasr@ppedv.de'          ,50000           ,'Chef'),
		('Maier'           ,'MUC'           ,'maier@ppedv.de'             ,50000           ,'Manager'),
		('Schmitt'         ,'COE'           ,'schmitt@ppedv.de'           ,50000           ,'AbtLeiter'),
		('Müller'          ,'BER'           ,'berlmue@ppedv.de'           ,50000           ,'Manager')


-- Funktion für Sicherheitsfilter erstellen
CREATE FUNCTION dbo.fn_hasAccess(@RoleOrUsername AS sysname)
    RETURNS TABLE
    WITH SCHEMABINDING -- Muss angegeben werden
AS
RETURN
(
  SELECT 1 'Granted' WHERE 
    USER_NAME() IN (@RoleOrUsername,'dbo') OR IS_MEMBER(ISNULL(@RoleOrUsername, 'dbo')) = 1
);
GO



CREATE SECURITY POLICY SecretFilter
ADD FILTER PREDICATE dbo.fn_hasAccess([SecColFilter]) ON [dbo].[Employees],
ADD BLOCK PREDICATE dbo.fn_hasAccess([SecColFilter]) ON [dbo].[Employees] AFTER INSERT,
ADD BLOCK PREDICATE dbo.fn_hasAccess([SecColFilter]) ON [dbo].[Employees] BEFORE DELETE,
ADD BLOCK PREDICATE dbo.fn_hasAccess([SecColFilter]) ON [dbo].[Employees] BEFORE UPDATE;
-- Weitere Filter/Blockprädikate für weitere Tabelle

GRANT SELECT, INSERT, DELETE, UPDATE ON [dbo].[Employees] TO PUBLIC;

-- Securtiy Policy aktivieren
ALTER SECURITY POLICY [dbo].[SecretFilter] WITH (STATE = ON);
-- Securtiy Policy deaktivieren
ALTER SECURITY POLICY [dbo].[SecretFilter] WITH (STATE = OFF);



ALTER TABLE [dbo].[Employees]
ALTER COLUMN [Name] ADD MASKED WITH (FUNCTION = 'partial(1,"-",2)');
ALTER TABLE [dbo].[Employees]
ALTER COLUMN [Address] ADD MASKED WITH (FUNCTION = 'default()');
ALTER TABLE [dbo].[Employees]
ALTER COLUMN [Email] ADD MASKED WITH (FUNCTION = 'email()');
ALTER TABLE [dbo].[Employees]
ALTER COLUMN [Salary] ADD MASKED WITH (FUNCTION = 'random(1, 1999)');



execute as user='Chef'
select * from employees
revert



execute as user='AbtLeiter'
select * from employees where salary < 50001 and salary > 49999
revert


execute as user='Manager'
select * from employees
revert

revert

GRANT UNMASK TO TestUser;  
EXECUTE AS USER = 'TestUser';  
SELECT * FROM Membership;  
REVERT;   

-- Removing the UNMASK permission  
REVOKE UNMASK TO TestUser;  
GRANT UNMASK TO Chef

execute as user='Manager'
select * from employees
revert

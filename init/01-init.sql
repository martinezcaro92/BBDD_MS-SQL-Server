\
-- 01-init.sql
-- Variables provided by sqlcmd: $(DBNAME), $(APPUSER), $(APPPASS)
:ON ERROR EXIT

IF DB_ID('$(DBNAME)') IS NULL
BEGIN
    PRINT 'Creating database [$(DBNAME)]...';
    EXEC('CREATE DATABASE [' + REPLACE('$(DBNAME)','''','''''') + ']');
END
GO

USE [$(DBNAME)];
GO

IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = '$(APPUSER)')
BEGIN
    PRINT 'Creating login [$(APPUSER)]...';
    DECLARE @sql nvarchar(max) = N'CREATE LOGIN [' + REPLACE('$(APPUSER)',']',']]') + N'] WITH PASSWORD = ''' + REPLACE('$(APPPASS)','''','''''') + N''', CHECK_POLICY = ON, CHECK_EXPIRATION = OFF';
    EXEC sp_executesql @sql;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = '$(APPUSER)')
BEGIN
    PRINT 'Creating user [$(APPUSER)] and granting db_owner...';
    EXEC(N'CREATE USER [' + REPLACE('$(APPUSER)',']',']]') + N'] FOR LOGIN [' + REPLACE('$(APPUSER)',']',']]') + N']');
    EXEC sp_addrolemember N'db_owner', N'$(APPUSER)';
END
GO

IF OBJECT_ID('dbo._probe','U') IS NULL
BEGIN
    CREATE TABLE dbo._probe(
        id INT IDENTITY(1,1) PRIMARY KEY,
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END
GO

INSERT INTO dbo._probe DEFAULT VALUES;
GO

PRINT 'Initialization complete.';
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBCheckI18nAll]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBCheckI18nAll]
GO

CREATE Procedure dbo.DBCheckI18nAll
 
As

-- Verify users are okay
exec dbo.DBCheckI18nUsers

-- Verify Table Conventions
exec dbo.DBCheckI18nTableConventions

-- Verify View Conventions
exec dbo.DBCheckI18nViewConventions

-- Verify data in Views for all Users
exec dbo.DBCheckI18nViews

if @@SERVERNAME not like '%STG%'
BEGIN
-- Verify all the web cache procs
EXEC dbo.DBCheckI18nWebCache
END

-- Verify Data in OTReports
--EXEC dbo.DBCheckI18nOTReportViews

go

GRANT EXECUTE ON [DBCheckI18nAll] TO ExecuteOnlyRole

GO

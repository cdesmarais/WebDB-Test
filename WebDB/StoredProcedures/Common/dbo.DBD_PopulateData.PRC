if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBD_PopulateData]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBD_PopulateData]
GO

CREATE PROCEDURE dbo.DBD_PopulateData
As
--***************************
--** TODO: This proc is obsolete (has been moved to LogDB)
--** Remove from CVS on DB
--***************************
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--Exec dbo.DBD_UpdateSearchAvailability
Exec dbo.DBD_UpdateSearchStatsSummary
Exec dbo.DBD_CacheDashboardStats

GO

GRANT EXECUTE ON [DBD_PopulateData] TO ExecuteOnlyRole

GO

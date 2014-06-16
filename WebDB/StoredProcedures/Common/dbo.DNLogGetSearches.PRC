if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNLogGetSearches]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNLogGetSearches]
GO

CREATE PROCEDURE dbo.DNLogGetSearches 

AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT * from WebSiteSearchLog

GO

GRANT EXECUTE ON [DNLogGetSearches] TO ExecuteOnlyRole

GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheWebValues]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheWebValues]
GO

CREATE PROCEDURE dbo.DNCacheWebValues
As
set nocount on
set transaction isolation level read uncommitted

exec dbo.procGetValueLookupsByType 'WEBSERVER'

GO

GRANT EXECUTE ON [DNCacheWebValues] TO ExecuteOnlyRole

GO

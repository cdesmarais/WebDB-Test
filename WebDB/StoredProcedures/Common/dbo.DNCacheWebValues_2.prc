
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheWebValues_2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheWebValues_2]
GO

CREATE PROCEDURE dbo.DNCacheWebValues_2
As
set nocount on
set transaction isolation level read uncommitted

exec dbo.procGetValueLookupsByType 'WEBSERVER'

GO

SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [DNCacheWebValues_2] TO ExecuteOnlyRole

GO

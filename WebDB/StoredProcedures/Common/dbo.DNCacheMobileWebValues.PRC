if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheMobileWebValues_2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheMobileWebValues_2]
GO



CREATE PROCEDURE dbo.DNCacheMobileWebValues_2
As
set nocount on
set transaction isolation level read uncommitted

exec dbo.procGetValueLookupsByType 'MOBILEWEB'

GO


GRANT EXECUTE ON [DNCacheMobileWebValues_2] TO ExecuteOnlyRole

--this proc is used in automation tests so adding permission for DBUser to call this proc.
GRANT EXECUTE ON [DNCacheMobileWebValues_2] TO DBAutomation

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheDown_V2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheDown_V2]
GO


CREATE Procedure dbo.DNCacheDown_V2
 (
  @CacheServerID int
 )
As
SET NOCOUNT ON
set transaction isolation level read uncommitted

update  CacheServer
set     DownDT_UTC = GETUTCDATE()
where   CacheServerID = @CacheServerID
and     datediff(mi, coalesce(DownDT_UTC, '01/01/1990'), GETUTCDATE()) > 10

GO

GRANT EXECUTE ON [DNCacheDown_V2] TO ExecuteOnlyRole

GO

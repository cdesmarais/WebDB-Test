if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantImporter_GetAllGroups]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantImporter_GetAllGroups]
GO

CREATE Procedure dbo.RestaurantImporter_GetAllGroups

AS

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

select		rtg.RID			RestaurantID
			,rg.GID			GroupID
			,rg.GroupName
from		RestaurantToGroup rtg
inner join	RestaurantGroup rg
on			rtg.gid = rg.gid
where		rtg.gid != -1
order by	rtg.RID

GO

GRANT EXECUTE ON [dbo].[RestaurantImporter_GetAllGroups] TO ExecuteOnlyRole

GO

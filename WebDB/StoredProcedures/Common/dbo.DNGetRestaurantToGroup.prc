if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetRestaurantToGroup]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetRestaurantToGroup]
GO


/*
Stored proc to return the RestaurantToGroup relationship for the web cache
*/
CREATE Procedure dbo.DNGetRestaurantToGroup

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

GRANT EXECUTE ON [dbo].[DNGetRestaurantToGroup] TO ExecuteOnlyRole

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AttributionService_GetRestaurantGroups]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AttributionService_GetRestaurantGroups]
GO

create procedure dbo.AttributionService_GetRestaurantGroups
as
set nocount on
set transaction isolation level read uncommitted

SELECT		distinct
			a.RID
			, b.RID as RestaurantInGroup
FROM
			(
			SELECT	rtg.RID
					,rtg.GID
					,n.MetroAreaID
			FROM		Restaurant r
			INNER JOIN	Neighborhood n 
			ON		r.neighborhoodID = n.neighborhoodID
			INNER JOIN	RestaurantToGroup rtg
			ON		r.RID = rtg.RID
			WHERE	r.RestStateID in (1,8)
			) as a

INNER JOIN	
			(
			SELECT	rtg.RID
					,rtg.GID
					,n.MetroAreaID
			FROM		Restaurant r
			INNER JOIN	Neighborhood n 
			ON		r.neighborhoodID = n.neighborhoodID
			INNER JOIN	RestaurantToGroup rtg
			ON		r.RID = rtg.RID
			WHERE	r.RestStateID in (1,8)
			) as b

ON			a.GID=b.GID
AND			a.MetroAreaID = b.MetroAreaID
WHERE			a.RID <> b.RID
ORDER BY		a.RID

GO

grant execute on [AttributionService_GetRestaurantGroups] to ExecuteOnlyRole

GO
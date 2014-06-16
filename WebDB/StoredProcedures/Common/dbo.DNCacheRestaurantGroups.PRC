if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheRestaurantGroups]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheRestaurantGroups]
GO


/*
This proc is used by OT_MgrCache/StoredProcTab.cs in ConsumerSite to fetch data for WebCache
*/
CREATE Procedure dbo.DNCacheRestaurantGroups

AS

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


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




GRANT EXECUTE ON [dbo].[DNCacheRestaurantGroups] TO ExecuteOnlyRole

GO

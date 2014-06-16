if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_GetListOfLanguages]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_GetListOfLanguages]
GO

CREATE Procedure dbo.Admin_Restaurant_GetListOfLanguages
 (
  @RestaurantID int
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT	l.LanguageID, 
	substring(l.[languageRegionDesc], 0, charindex(' - ', l.[languageRegionDesc])) AS Language,
	r.RID AS RestaurantID,
	n.NeighborhoodID,
	case when exists 
		(select * from restaurantLocal rl 
			where rl.RID = r.RID
			and rl.LanguageID = l.languageID)
		 then 1 else 0 end as RestInfoExist
FROM restaurant r
inner join neighborhoodAVW n
on r.NeighborhoodID = n.NeighborhoodID
Inner join Language l
on n.languageID = l.LanguageID
WHERE	(r.rid = @RestaurantID)

GO

GRANT EXECUTE ON [Admin_Restaurant_GetListOfLanguages] TO ExecuteOnlyRole

GO

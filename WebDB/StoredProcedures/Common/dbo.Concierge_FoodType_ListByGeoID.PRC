if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_FoodType_ListByGeoID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_FoodType_ListByGeoID]
GO

CREATE PROCEDURE dbo.Concierge_FoodType_ListByGeoID
 (
  @GeoID int
 )
As
--***************************************
--** Legacy APIs called by go.concierge uses opentable.dll
--***************************************

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT DISTINCT 
    ft.FoodTypeID AS FoodTypeID
    ,ft.FoodType AS FoodTypeName
FROM FoodType ft
INNER JOIN FoodTypes fts
ON ft.FoodTypeID = fts.FoodTypeID 
INNER JOIN   RestaurantVW r
ON  fts.RID = r.RID 
and r.LanguageID = ft.LanguageID
AND (r.RestStateID = 1) 
AND  (r.Allotment <> 1) --** EV: 11/30/2009: Never allow allotment / console in legacy APIs
INNER JOIN  Neighborhood n 
ON  r.NeighborhoodID = n.NeighborhoodID
and (n.MetroAreaID = @GeoID) 
WHERE ft.FoodTypeID = ft.sftid
ORDER BY ft.FoodType

GO

GRANT EXECUTE ON [Concierge_FoodType_ListByGeoID] TO ExecuteOnlyRole

GO

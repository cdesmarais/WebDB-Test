if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_ListFavoriteDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_ListFavoriteDetails]
GO

CREATE Procedure dbo.User_ListFavoriteDetails 
 (
   @UserID int
  ,@GeoID int
  ,@IsCaller int = 0  
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @time_offset real
select  @time_offset= 3.0 
select  @time_offset= @time_offset / 24 / 60

if @IsCaller = 0

BEGIN
  SELECT r.RID AS RestaurantID
    ,r.RName              AS RestaurantName
    ,r.Address1          AS Address
    ,r.City 
    ,r.State
    ,r.Zip       AS Zip 
    ,r.NeighborhoodID   AS NeighborhoodID 
    ,n.NbhoodName            AS NeighborhoodName
    ,
(Case when(PriceQuartileID=5) then 0 else PriceQuartileID end) as PriceQuartileID
    ,ft.FoodType              AS FoodType
   ,CASE WHEN r.RestStateID = 1 
         THEN CASE WHEN((r.IsReachable = 1) 
                         or (r.Allotment = 1 and r.RestStateID = 1))
                   THEN 1 
                   ELSE 4 
              END 
         ELSE r.RestStateID 
    END AS RestaurantState
   ,CASE WHEN r.RestStateID = 1 AND ((r.IsReachable = 1) or
    (r.Allotment = 1 and r.RestStateID = 1))
    THEN 1 ELSE 0 END AS IsAvailable
   ,coalesce((SELECT -1
              FROM Favorites
              WHERE Favorites.CustID = @UserID 
              AND   Favorites.RID = r.RID)
             ,0) AS IsFavorite
  FROM       RestaurantVW r
  INNER JOIN NeighborhoodAVW n
  ON         r.NeighborhoodID = n.NeighborhoodID 
  and		 r.LanguageID = n.LanguageID
  INNER JOIN FoodTypes fts
  ON         r.RID = fts.RID 
  INNER JOIN FoodType ft
  ON         fts.FoodTypeID = ft.FoodTypeID 
  and		 r.LanguageID = ft.LanguageID
  WHERE     (n.MetroAreaID = @GeoID) 
  AND       (r.RestStateID  in (1,5,6,13))  
  AND       (fts.IsPrimary = 1)
  ORDER BY   IsFavorite
            ,r.RName
END 

if @IsCaller > 0

BEGIN
  SELECT r.RID AS RestaurantID
    ,r.RName              AS RestaurantName
    ,r.Address1          AS Address
    ,r.City
    ,r.State
    ,r.Zip       AS Zip
    ,r.NeighborhoodID   AS NeighborhoodID
    ,n.NbhoodName            AS NeighborhoodName
    ,r.PriceQuartileID
    ,ft.FoodType              AS FoodType
    ,CASE WHEN r.RestStateID = 1 
         THEN CASE WHEN((r.IsReachable = 1) 
                         or (r.Allotment = 1 and r.RestStateID = 1))
                   THEN 1 
                   ELSE 4 
              END 
         ELSE r.RestStateID 
    END AS RestaurantState
   ,CASE WHEN r.RestStateID = 1 AND ((r.IsReachable = 1) or
    (r.Allotment = 1 and r.RestStateID = 1))
    THEN 1 ELSE 0 END AS IsAvailable
   ,coalesce((SELECT -1
              FROM  CallerRestaurants cr
              WHERE cr.CallerID = @UserID 
              AND   cr.RID = r.RID)
         ,0) AS IsFavorite
  FROM       RestaurantVW r
  INNER JOIN NeighborhoodAVW n
  ON         r.NeighborhoodID = n.NeighborhoodID
  and		 r.LanguageID = n.LanguageID
  INNER JOIN FoodTypes fts
  ON         r.RID = fts.RID 
  INNER JOIN FoodType ft
  ON         fts.FoodTypeID = ft.FoodTypeID 
  and		 r.LanguageID = ft.LanguageID
  WHERE     (n.MetroAreaID = @GeoID) 
  AND       (r.RestStateID in (1,5,6,13))  
  AND       (fts.IsPrimary = 1)
  ORDER BY   IsFavorite
            ,r.RName
END
GO

GRANT EXECUTE ON [User_ListFavoriteDetails] TO ExecuteOnlyRole

GO

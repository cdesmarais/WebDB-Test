if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUserListFavoriteDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUserListFavoriteDetails]
GO



CREATE Procedure dbo.DNUserListFavoriteDetails 
 (
   @UserID int
  ,@GeoID int
  ,@IsCaller int = 0  --this param really just indicates if @UserID is a user_id or a caller_id
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted


if @IsCaller = 0
BEGIN
  SELECT r.RID AS RestaurantID
    ,r.Rname              AS RestaurantName
    ,r.Address1          AS Address
    ,r.City 
    ,r.State
    ,r.Zip       AS Zip 
    ,r.neighborhoodid   AS NeighborhoodID 
    ,n.NBhoodName            AS NeighborhoodName
    ,
(Case when(PriceQuartileID=5) then 0 else PriceQuartileID end) as PriceQuartileID
    ,ft.FoodType              AS FoodType
   ,r.RestStateID AS RestaurantState
	,CASE 
	   WHEN (r.RestStateID = 1 AND r.IsReachable = 1)
	  	THEN r.IsReachable
	   ELSE cast(0 as bit)
	 END AS IsAvailable
   ,coalesce((SELECT -1
              FROM Favorites
              WHERE Favorites.CustID = @UserID 
              AND   Favorites.RID = r.RID)
             ,0) AS IsFavorite, co.CountryID
	,CASE WHEN (LEN(LTRIM(RSName)) = 0) THEN RName ELSE RSName END AS RSName
	,CASE WHEN (LEN(LTRIM(n.NbhoodSName)) = 0) THEN n.NbhoodName ELSE n.NBhoodSName END AS NeighborhoodSName
	,CASE WHEN (LEN(LTRIM(ft.FoodTypeSName)) = 0) THEN ft.FoodType ELSE ft.FoodTypeSName END AS FoodTypeSName
  FROM       RestaurantVW r
  INNER JOIN country co
  on co.countryid = r.country
  INNER JOIN NeighborhoodAVW n
  ON         n.neighborhoodid = r.neighborhoodid 
  and		 n.LanguageID = r.LanguageID
  INNER JOIN FoodTypes fts
  ON         r.RID = fts.RID 
  INNER JOIN FoodType ft
  ON         fts.foodtypeID = ft.foodtypeID 
  AND		ft.LanguageID = r.LanguageID		
  WHERE     (n.metroareaid = @GeoID) 
  AND       (r.RestStateID in (1,5,6,7,16,13))  
  AND       (fts.IsPrimary = 1)
  ORDER BY   IsFavorite
            ,r.Rname
END

if @IsCaller > 0
BEGIN
  SELECT r.RID AS RestaurantID
    ,r.Rname              AS RestaurantName
    ,r.Address1          AS Address
    ,r.City
    ,r.State
    ,r.Zip       AS Zip
    ,r.neighborhoodid   AS NeighborhoodID
    ,n.NBhoodName            AS NeighborhoodName
    ,r.PriceQuartileID
    ,ft.FoodType              AS FoodType
   ,r.RestStateID AS RestaurantState
	,CASE 
	   WHEN (r.RestStateID = 1 AND r.IsReachable = 1)
	  	THEN r.IsReachable
	   ELSE cast(0 as bit)
	 END AS IsAvailable
   ,coalesce((SELECT distinct -1
              FROM  CallerRestaurants cr
              WHERE cr.CallerID = @UserID 
              AND   cr.RID = r.RID) ,0) AS IsFavorite,
          co.CountryID
	,CASE WHEN (LEN(LTRIM(r.RSName)) = 0) THEN r.RName ELSE r.RSName END AS RSName
	,CASE WHEN (LEN(LTRIM(n.NbhoodSName)) = 0) THEN n.NbhoodName ELSE n.NBhoodSName END AS NeighborhoodSName
	,CASE WHEN (LEN(LTRIM(ft.FoodTypeSName)) = 0) THEN ft.FoodType ELSE ft.FoodTypeSName END AS FoodTypeSName
  FROM       RestaurantVW r
  INNER JOIN country co
  on co.countryid = r.country
  INNER JOIN NeighborhoodAVW n
  ON         n.neighborhoodid = r.neighborhoodid 
  and		 n.LanguageID = r.LanguageID
  INNER JOIN FoodTypes fts
  ON         r.RID = fts.RID 
  INNER JOIN FoodType ft
  ON         fts.foodtypeID = ft.foodtypeID 
  AND		ft.LanguageID = r.LanguageID
  WHERE     (n.metroareaid = @GeoID) 
  AND       (r.RestStateID in (1,5,6,7,16,13))  
  AND       (fts.IsPrimary = 1)
  ORDER BY   IsFavorite
            ,r.Rname
END
GO

GRANT EXECUTE ON [DNUserListFavoriteDetails] TO ExecuteOnlyRole

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Caller_ListFavoriteDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Caller_ListFavoriteDetails]
GO

CREATE Procedure dbo.Concierge_Caller_ListFavoriteDetails
 (
  @UserID int,
  @GeoID int,
  @Folder int
 )
As
--***************************************
--** Legacy APIs called by go.concierge uses opentable.dll
--***************************************

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT 
	 r.RID AS RestaurantID
	,r.RName AS RestaurantName
	,r.Address1 AS Address
    ,r.City
	,r.State
	,r.Zip AS Zip
	,r.NeighborhoodID AS NeighborhoodID
	,n.NbhoodName AS NeighborhoodName
	,ft.FoodType AS FoodType
	,coalesce((SELECT -1
	FROM CallerRestaurants cr
	WHERE cr.CallerID = @UserID 
	AND cr.RID = r.RID 
	AND cr.FolderID = @Folder),
    0) AS IsFavorite
,CASE	WHEN r.RestStateID = 1 
	THEN CASE	WHEN ((r.IsReachable = 1) or (r.Allotment = 1 and r.RestStateID = 1))
			THEN 1 
			ELSE 4 END 
	ELSE r.RestStateID END
    AS RestaurantState
,CASE WHEN r.RestStateID = 1 AND 
    ((r.IsReachable = 1) or
    (r.Allotment = 1 and r.RestStateID = 1))
    THEN 1 ELSE 0 END AS IsAvailable
    
FROM		RestaurantVW r
INNER JOIN	NeighborhoodAVW n
ON		    r.NeighborhoodID = n.NeighborhoodID 
and			n.LanguageID = r.LanguageID
INNER JOIN	FoodTypes fts
ON		    r.RID = fts.RID 
INNER JOIN	FoodType ft
ON		    fts.FoodTypeID = ft.FoodTypeID 
AND			ft.LanguageID = r.LanguageID
WHERE		(n.MetroAreaID = @GeoID) 
AND		    (r.RestStateID in (1,5,6,7,13)) 
AND		    (fts.IsPrimary = 1)

AND			r.Allotment <> 1 --** EV: 11/30/2009: Never allow allotment / console in legacy APIs

ORDER BY	IsFavorite
		   ,r.RName
		   
GO

GRANT EXECUTE ON [Concierge_Caller_ListFavoriteDetails] TO ExecuteOnlyRole

GO

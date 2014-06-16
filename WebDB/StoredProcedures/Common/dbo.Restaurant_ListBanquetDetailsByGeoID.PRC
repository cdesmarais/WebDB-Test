if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_ListBanquetDetailsByGeoID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_ListBanquetDetailsByGeoID]
GO

CREATE Procedure dbo.Restaurant_ListBanquetDetailsByGeoID
 (
  @GeoID int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT		r.RID AS RestaurantID
			,r.RName AS RestaurantName
			,r.Address1 AS Address
			,r.City
			,r.State
			,r.Zip AS Zip
			,n.NbhoodName AS NeighborhoodName
			,ft.FoodType AS FoodType
			,rd.PrivatePartyDescription AS PartyDescription
			,rd.BanquetDescription AS BanquetDescription
			,r.HasBanquet AS HasBanquetOption
			,r.HasPrivateParty AS HasPartyOption
			,r.BanquetContact AS BanquetContact
			,r.PrivatePartyContact AS PartyContact
			,r.BanquetPhone AS BanquetPhone
			,r.PrivatePartyPhone AS PartyPhone
FROM		RestaurantVW r
INNER JOIN	NeighborhoodAVW n 
ON			n.NeighborhoodID = r.NeighborhoodID 
AND			n.LanguageID = r.LanguageID
INNER JOIN	FoodTypes fts
ON			r.RID = fts.RID 
INNER JOIN	FoodType ft
ON			fts.FoodTypeID = ft.FoodTypeID 
AND			ft.LanguageID = r.LanguageID
INNER JOIN	RestaurantMessageVW rd
ON			r.RID = rd.RID
AND			r.LanguageID = rd.LanguageID
WHERE		(n.MetroAreaID = @GeoID) 
AND			(fts.IsPrimary = 1) 
AND			(r.RestStateID in(1,2,3))
ORDER BY	r.RName

GO

GRANT EXECUTE ON [Restaurant_ListBanquetDetailsByGeoID] TO ExecuteOnlyRole

GO

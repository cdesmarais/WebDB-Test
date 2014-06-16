if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_GetDetailsByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_GetDetailsByID]
GO

CREATE Procedure dbo.Restaurant_GetDetailsByID
(
@RestaurantID int
)
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @time_offset real
select @time_offset= 3.0
select @time_offset= @time_offset / 24 / 60

SELECT 
			r.RName AS RestaurantName
			,CASE WHEN ((r.RestStateID = 1 AND r.IsReachable = 1) or (r.Allotment = 1) AND(r.RestStateID = 1))
			THEN 1 ELSE 0 END AS RestaurantState
			,rm.RMDesc as Description
			,r.Address1
			,r.Address2
			,r.City
			,r.State
			,r.Zip AS ZipCode
			,r.Country
			,r.Email
			,r.ExternalURL AS URL
			,r.Chef
			,ds.DiningStyle AS DiningStyle
			,dc.DressCode AS DressCode
			,wo.WalkinOption AS Walkin
			,rm.Entertainment
			,p.Parking AS Parking
			,rm.ParkingDescription AS ParkingDescription
			,rm.BanquetDescription AS BanquetDescription
			,rm.PrivatePartyDescription AS PrivatePartyDescription
			,HasGiftCertificate AS HasGiftCertificate
			,GiftCertificateCode AS GiftCertificateCode
			,rm.PublicTransit AS PublicTransit
			,rm.Hours AS Hours
			,Phone As Phone
			,BanquetContact AS BanquetContact
			,coalesce(CrossStreet,'') AS CrossStreet
			,PrivatePartyContact AS PrivatePartyContact
			,PrivatePartyPhone AS PrivatePartyPhone
			,BanquetPhone AS BanquetPhone
			,PriceQuartile.PriceQuartileID AS Price
			,r.HasBanquet AS Has_Banquet
			,r.HasPrivateParty AS Has_Private_Party
			,rm.CaterDescription as Cater_Description
			,r.HasCatering as Has_Catering
			,n.MetroAreaID as Metro_area_ID
			,AcceptCheque as Accept_Cheque
			,RestStateID as Restaurant_State_ID
			,n.NbhoodName as NeighborhoodName
			,coalesce(RestaurantNetvisit.NetvisitID,0) as NetvisitID
			,FoodType.FoodType as Cuisine
			, n.NeighborhoodID
FROM		RestaurantVW r
INNER JOIN	DiningStyleLocal ds 
ON			ds.DiningStyleID = r.DiningStyleID
and			ds.LanguageID = r.LanguageID
INNER JOIN DressCodeLocal dc 
ON			dc.DressCodeID = r.DressCodeID
and			dc.LanguageID = r.LanguageID
INNER JOIN	WalkinOptionLocal wo
ON			wo.WOID = r.WOID
and			wo.LanguageID = r.LanguageID
INNER JOIN	ParkingLocal p
ON			p.ParkingID = r.ParkingID 
and			p.LanguageID = r.LanguageID
INNER JOIN	RestaurantMessageAVW rm 
ON			r.RID = rm.RID 
AND			r.LanguageID = rm.LanguageID
INNER JOIN	PriceQuartileAVW PriceQuartile
ON			r.PriceQuartileID=PriceQuartile.PriceQuartileID 
AND			r.LanguageID = PriceQuartile.LanguageID
AND			r.Country = PriceQuartile.CountryID
INNER JOIN	NeighborhoodAVW n 
ON			r.NeighborhoodID= n.NeighborhoodID 
and			n.LanguageID = r.LanguageID
INNER JOIN	FoodTypes 
ON			r.RID= FoodTypes.RID 
and			IsPrimary = 1
INNER JOIN	FoodType 
ON			FoodTypes.FoodTypeID= FoodType.FoodTypeID 
AND			FoodType.LanguageID = r.LanguageID
Left Join	RestaurantNetvisit 
on			r.RID = RestaurantNetvisit.RID
WHERE		(r.RID = @RestaurantID)
order by	IsPrimary desc

GO

GRANT EXECUTE ON [Restaurant_GetDetailsByID] TO ExecuteOnlyRole

GO

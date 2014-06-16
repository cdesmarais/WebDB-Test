if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantImporter_GetAllRestaurantDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantImporter_GetAllRestaurantDetails]
GO

CREATE Procedure dbo.RestaurantImporter_GetAllRestaurantDetails
As

	set transaction isolation level read uncommitted
	set nocount on

SELECT
	 r.RID as  RestaurantID
	,r.RestStateID
	,r.RName AS RestaurantName
	,r.RSName AS RestaurantSortableName
	,(Case when(r.PriceQuartileID=5) then 0 else r.PriceQuartileID end) AS Price_Quartile_ID
	,coalesce(rm.Message,'') as Description
	,coalesce(p.Parking,'') As Parking
	,coalesce(r.CrossStreet,'') As CrossStreet
	,r.Address1 AS Address1
	,r.Address2 AS Address2
	,r.City
	,r.State
	,r.Zip AS Zip
	,co.countryName
	,co.CountryID
	,r.NeighborhoodID AS NeighborhoodID
	,n.MetroAreaID As MetroID
	,n.MacroID
	,r.latitude
	,r.longitude
	,r.MaxLargePartyID AS MaxPartySize
	,l.LanguageCode
	,l.LanguageID
	,r.DomainID
	,ft.FoodTypeID as FoodTypeID
	,ft.GUID as FoodTypeGUID
	,r.ShowThirdPartyMenu
	,r.MenuURL
	,coalesce(rmenu.IsAccessible, 0) as MenuURLAccessible
	,r.Chef
	,dc.DressCode AS DressCode
	,ds.DiningStyle AS DiningStyle
	,pq.PriceQuartile as PriceDescription
	,pq.Symbols as PriceBandSymbols
	,co.CurrencySymbol
	,pq.CurrencyType
	,rja.DateAdded as RestaurantInstallDate
	,rja.JustAdded
	,rja.DateRemoved
	,rja.OverrideDate as DateRemovedOverride
	,CASE
       WHEN COALESCE(foodSpottingOptOut.ValueID, 0) > 0 THEN 1
       ELSE 0
     END as FoodSpottingOptOut
    ,r.Phone as PhoneNumber
    ,r.HasPrivateParty as HasPrivateDining
    ,r.PublishPrivateDining as HasEnhancedPrivateDining
	,r.PrivatePartyPhone as PrivateDiningPhone
    ,r.PrivatePartyContact as PrivateDiningContact
    ,r.PrivatePartyEmail as PrivateDiningEmail
    ,r.AcceptFlower as AcceptsFlowers
    ,CASE
       WHEN COALESCE(limoSuppression.ValueID, 0) > 0 THEN 1
       ELSE 0
     END as IsLimoServiceSuppressed
    ,r.WOID as WalkinOption
    ,r.ExternalURL
    ,r.FacebookURL
	,r.AdWordsID
	,r.AdWordsValue
	,mao.Days as MaxAdvanceDays
	,r.Email
	,rtf.TreatfulURL
	,r.TwitterAccountName
	,r.Allotment
	,r.RestaurantType AS [Type]
	,r.IsConnectFieldTest
FROM		RestaurantAVW r
INNER JOIN	countryAVW co
on			co.countryid = r.country
and			co.LanguageID = r.LanguageID
LEFT JOIN RestaurantCustomMessage rm
ON			r.RID = rm.RID
and			r.LanguageID = rm.LanguageID
and			rm.messageTypeID = 51
Left JOIN ParkingLocal p
ON			r.ParkingID = p.ParkingID
and			r.LanguageID = p.LanguageID
INNER JOIN FoodTypes fts
ON			r.RID = fts.RID
AND			isPrimary = 1
INNER JOIN	FoodType ft
ON			fts.FoodTypeID = ft.FoodTypeID
AND			ft.LanguageID = r.LanguageID
INNER JOIN	Language l
on			l.LanguageID = r.LanguageID
INNER JOIN	Domain d
ON			R.DomainID = d.DomainID
LEFT JOIN RestaurantMenuAccess rmenu
on 			r.RID = rmenu.RID
LEFT JOIN RestaurantMenuFormat rmf
on 			rmenu.MenuFormatID = rmf.MenuFormatID
INNER JOIN	DiningStyleLocal ds
ON			r.DiningStyleID = ds.DiningStyleID
and			ds.LanguageID = r.LanguageID
INNER JOIN	DressCodeLocal dc
ON			r.DressCodeID = dc.DressCodeID
and			dc.LanguageID = r.LanguageID
INNER JOIN	PriceQuartileAVW pq
ON			pq.PriceQuartileID = r.PriceQuartileID
and			pq.LanguageID = r.LanguageID
and			pq.CountryID = r.Country
INNER JOIN Neighborhood n
ON			r.NeighborhoodID = n.NeighborhoodID
LEFT JOIN RestaurantJustAdded rja
ON			r.RID = rja.RID
LEFT OUTER JOIN	ValueLookupIDList foodSpottingOptOut
ON 			foodSpottingOptOut.LookupID = 63
AND 		r.rid = foodSpottingOptOut.ValueID
LEFT OUTER JOIN ValueLookupIDList limoSuppression
ON          limoSuppression.LookupID = 23
AND         r.rid = limoSuppression.ValueID
INNER JOIN MaxAdvanceOption mao
ON r.MaxAdvanceOptionID = mao.MaxAdvanceOptionID
LEFT JOIN RestaurantTreatful rtf
ON r.RID = rtf.RID

GO

GRANT EXECUTE ON [RestaurantImporter_GetAllRestaurantDetails] TO ExecuteOnlyRole

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantListBanquetDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantListBanquetDetails]
GO

CREATE Procedure dbo.DNRestaurantListBanquetDetails

As

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT 
			 r.RID AS RestaurantID
			,r.RName AS RestaurantName
			,r.Address1 AS Address
			,r.City
			,r.State
			,r.Zip AS Zip
		    ,c.CountryName
		    ,c.CountryCode
		    ,c.CountryID
			,n.NbhoodName AS NeighborhoodName
			,ft.FoodType AS FoodType
			,(SELECT Message FROM RestaurantCustomMessageVW WHERE rid = r.rid AND MessageTypeID = 54 AND r.LanguageID = LanguageID) AS PartyDescription
			,(SELECT Message FROM RestaurantCustomMessageVW WHERE rid = r.rid AND MessageTypeID = 59 AND r.LanguageID = LanguageID) AS PartyLongDescription
			,r.HasPrivateParty AS HasPartyOption
			,PrivatePartyContact AS PartyContact
			,PrivatePartyPhone AS PartyPhone
			,n.MacroID
			,n.MetroAreaID
			,r.RSName
			,r.Country
			,ft.foodtypeID
			,r.PriceQuartileID
			,r.NeighborhoodID
			,coalesce(r.LargestCapacity,0) AS LargestCapacity
			,r.EnablePrivateDining
			,r.PublishPrivateDining
			,coalesce(ri.PrivateDiningThumbnail,'') as PrivateDiningThumbnail
			,(case when left(r.RName, 4) = 'The ' then substring(r.RName, 5, Len(r.RName)-4) else r.RName end) as RNameSort	
			,(case when left(r.RSName, 4) = 'The ' then substring(r.RSName, 5, Len(r.RSName)-4) else r.RSName end) as RSNameSort

FROM		RestaurantVW r 
INNER JOIN	CountryAVW c
ON			c.CountryID = r.Country
and			c.LanguageID = r.LanguageID
INNER JOIN	NeighborhoodAVW n 
ON			n.neighborhoodid = r.neighborhoodid 
and			n.LanguageID = r.LanguageID
LEFT OUTER JOIN RestaurantImage ri
ON			r.RID = ri.RID
INNER JOIN	FoodTypes fts
ON			r.RID = fts.RID 
and			fts.IsPrimary = 1
inner join	FoodType ft
on			fts.FoodTypeID = ft.FoodTypeID
and			ft.LanguageID = r.LanguageID
WHERE		r.RestStateID in(1,5,6,7,16,13)
and			r.HasPrivateParty <> 0	
order by	RSNameSort asc, RNameSort asc

GO


GRANT EXECUTE ON [DNRestaurantListBanquetDetails] TO ExecuteOnlyRole

GO
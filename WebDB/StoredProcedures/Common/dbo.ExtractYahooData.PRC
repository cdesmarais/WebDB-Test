
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ExtractYahooData]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ExtractYahooData]
GO

CREATE procedure dbo.ExtractYahooData

as

set transaction isolation level read uncommitted


SELECT  
			r.rid 'RestaurantID'
			,cast(r.RName as nvarchar(60)) 'RestaurantName'
			,cast(coalesce(Address1,'') +' '+ coalesce(Address2,'') as nvarchar(120)) 'Address'
			,cast(r.City as nvarchar(28)) 'City'
			,cast(r.State as nvarchar(3)) 'State'
			,cast(r.Zip as nvarchar(11)) 'PostalCode'
			,cast(r.Country as nvarchar(3)) 'Country'
			,replace(replace(RMDesc, char(10), ''), char(13), ' ') 'RestaurantDescription'
			,cast(ds.DiningStyle as nvarchar(15)) 'DiningStyle'
			--,coalesce((Select FoodType from FoodTypes fts inner join FoodType ft on fts.FoodTypeID = ft.FoodTypeID where isPrimary = 1 and fts.rid = r.rid),'') + ',' + 
			--coalesce((Select max(FoodType) from FoodTypes fts inner join FoodType ft on fts.FoodTypeID = ft.FoodTypeID where isPrimary = 0 and fts.rid = r.rid),'')  + ',' + 
			--coalesce((Select min(FoodType) from FoodTypes fts inner join FoodType ft on fts.FoodTypeID = ft.FoodTypeID where isPrimary = 0 and fts.rid = r.rid having count(rid) > 1),'') 'Cusine Types'
			,coalesce(dbo.fGetCusineTypes (r.RID, r.LanguageID),'') 'Cusine Types'
			,cast(n.NBhoodName as nvarchar(36)) 'Neighborhood'
			,coalesce(r.CrossStreet,'None Provided') 'CrossStreet'
			,cast(pq.PriceQuartile as nvarchar(15)) 'Price'
			,coalesce(ExternalURL,'None Provided') 'WebSiteAddress'
			,coalesce(Email,'None Provided') 'EmailAddress'
			,coalesce(cast(replace(replace(rm.hours, char(10), ''), char(13), ' ') as nvarchar(750)),'') 'Hours'
			,coalesce (ReservationPhone,Phone) 'PhoneNumber'
			,cast(coalesce(r.Chef,'None Listed') as nvarchar(140)) 'ExecutiveChef'
			,coalesce(replace(replace(rm.PublicTransit, char(10), ''), char(13), ' '), 'None Listed') 'PublicTransit'
			,cast(dc.DressCode as nvarchar(25)) 'DressCode'
			,cast(wo.WalkInOption as nvarchar(4)) 'WalkinAllowed'
			,coalesce(dbo.fGetOfferNames (r.RID),'') 'Offers'
			,case when p.ParkingID = 1 then 'No' else cast(coalesce(p.Parking,'Yes') as nvarchar(15)) end  'ParkingDetails'
			,'' as 'SmokingPolicy'
			,case when HasBanquet = 0 then 'No' else 'Yes' end  'BanquetFacilities'
			,coalesce(BanquetPhone, 'No') 'BanquetPhone'
			,case when HasPrivateParty = 0 then 'No' else 'Yes' end  'PrivateParty'
			,coalesce(PrivatePartyContact, 'No') 'PrivatePartyContact'
			,coalesce(PrivatePartyPhone, 'No') 'PrivatePartyPhone'
			,'http://www.opentable.com/single.aspx?rid=' + cast(r.RID as nvarchar(10)) + '&ref=769' as  RefURL

FROM		RestaurantVW r

inner join	ParkingLocal p
on			p.ParkingID = r.ParkingID
and			p.LanguageID = r.LanguageID

inner join	DressCodeLocal dc
on			dc.DressCodeID = r.DressCodeID
and			dc.LanguageID = r.LanguageID

INNER JOIN	PriceQuartileAVW pq
ON		r.PriceQuartileID=pq.PriceQuartileID 
AND		r.Country = pq.CountryID
and		r.LanguageID = pq.LanguageID

inner join	WalkinOptionLocal wo
on			wo.WOID = r.WOID
and			wo.LanguageID = r.LanguageID

inner join	NeighborhoodAVW n
on			n.NeighborhoodID = r.NeighborhoodID
and			n.LanguageID = r.LanguageID

inner join	MetroAreaAVW ma
on			ma.MetroAreaID = n.MetroAreaID
and			ma.LanguageID = r.LanguageID

inner join	DiningStyleLocal ds
on			ds.DiningStyleID = r.DiningStyleID
and			ds.LanguageID = r.LanguageID

inner join	RestaurantMessageAVW rm
on			rm.RID = r.RID
and			rm.LanguageID = r.LanguageID

where		r.RestStateID = 1 
and			ma.active = 1
and			ma.MetroAreaID not in (1, 58) -- Always exlcude Exlusive and Demoland

GO

GRANT EXECUTE ON [ExtractYahooData] TO ExecuteOnlyRole

GO

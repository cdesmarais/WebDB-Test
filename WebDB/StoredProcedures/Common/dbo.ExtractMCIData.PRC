
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ExtractMCIData]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ExtractMCIData]
GO

CREATE procedure dbo.ExtractMCIData

as

set transaction isolation level read uncommitted

SELECT  
			cast(ma.MetroAreaName as nvarchar(28)) 'MetroName'
			,cast(r.RName as nvarchar(60)) 'RestaurantName'
			,cast(pq.PriceQuartile as nvarchar(15)) 'Price'
			,coalesce(ExternalURL,'None Provided') 'URL'
			,cast(n.NBhoodName as nvarchar(36)) 'NeighborhoodName'
			,ft.FoodType 'PrimaryFoodType'
			,cast(coalesce(Address1,'') +' '+ coalesce(Address2,'') as nvarchar(120)) 'Address'
			,cast(r.City as nvarchar(28)) 'City'
			,cast(r.State as nvarchar(3)) 'State'
			,cast(r.Zip as nvarchar(11)) 'PostalCode'
			,coalesce (ReservationPhone,Phone) 'Phone'
			,r.RID 'RestaurantID'
			,'http://www.opentable.com/single.asp?id='+cast(r.RID as nvarchar(5)) as ReserveURL
			,replace(replace(RMDesc, char(10), ''), char(13), ' ') 'RestaurantDescription'
			,cast(ds.DiningStyle as nvarchar(15)) 'DiningStyle'
			,coalesce(r.CrossStreet,'None Provided') 'CrossStreet'
			,coalesce(cast(replace(replace(rm.hours, char(10), ''), char(13), ' ') as nvarchar(750)),'') 'Hours'
			,coalesce(replace(replace(rm.PublicTransit, char(10), ''), char(13), ' '), 'None Listed') 'PublicTransit'
			,cast(coalesce(r.Chef,'None Listed') as nvarchar(140)) 'ExecutiveChef'
			,cast(dc.DressCode as nvarchar(25)) 'DressCode'
			,cast(wo.WalkInOption as nvarchar(4)) 'WalkinAllowed'
			,coalesce(dbo.fGetOfferNames (r.RID),'') 'Offers'
			,case when p.ParkingID = 1 then 'No' else 'Yes' end  'Parking'
			,cast(p.Parking as nvarchar(15)) 'ParkingDetails'
			,coalesce(dbo.fGetPaymentTypes (r.RID),'') 'PaymentOptions'
			,case when r.HasCatering = 1 then 'Yes' else 'No' end  'Catering'
			,case when HasPrivateParty = 0 then 'No' else 'Yes' end  'PrivateParty'
			,coalesce(PrivatePartyContact, 'No') 'PrivatePartyContact'


FROM		RestaurantVW r

inner join	FoodTypes fts
on			fts.RID = r.RID
and			fts.IsPrimary = 1

inner join	FoodType ft
on			ft.FoodTypeID = fts.FoodTypeID
and			ft.LanguageID = r.LanguageID

inner join	ParkingLocal p
on			p.ParkingID = r.ParkingID
and			p.LanguageID = r.LanguageID

inner join	Smoking	s
on			s.SmokingID = r.SmokingID

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

where		r.RestStateID = 1 and ma.active = 1
GO


GRANT EXECUTE ON [ExtractMCIData] TO ExecuteOnlyRole

GO

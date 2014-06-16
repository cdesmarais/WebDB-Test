if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTR_Restaurant_GetInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTR_Restaurant_GetInfo]
GO


create procedure [dbo].[OTR_Restaurant_GetInfo]
(
	@RID int,
	@LanguageID int
)
as
set NOCOUNT on
set transaction ISOLATION LEVEL read UNCOMMITTED  

select 
	r.[RID]
	,[RName]
	,[RSName]
	,r.[NeighborhoodID]
	,[Address1]
	,[Address2]
	,[City]
	,[State]
	,[ZIP]
	,[Country]
	,[MappingAddress]
	,[Latitude]
	,[Longitude]
	,c.AddressFormat as AddressFormat
	,c.MapLink as MapLinkTemplate
	,convert(INT,r.MapAddrValid) as MapAddrValid
	,[CrossStreet]
	,[ParkingID]
	,[ParkingDescription]
	,[PublicTransit]
	,[ExternalURL]
	,[Email]
	,[ReserveCode]
	,[MenuURL]
	,[Phone] as ReservationPhone
	,[FaxPhone]
	,[RMDesc] as Description
	,[Hours]
	,[Chef]
	,[DiningStyleID]
	,[DressCodeID]
	,[PriceQuartileID]
	,[WOID] as WalkinOptionID
	,[MinOnlineOptionID] as MinPartySize
	,[MinCCOptionID] as MinCCPartySize
	,[MaxLargePartyID] as MaxLargePartySize
	,[AcceptLargeParty] as AcceptLargeParty --MMC TT31128
	,[Confirmation] as ConfirmationMessage
	,[SpecialEvents] as SpecialEvents
	,[MaxAdvanceOptionID] as HowFar
	,[SpecialEventsStartDate] as SpecialEventStartDate
	,[SpecialEventsEndDate] as SpecialEventEndDate
	,[PrivatePartyPhone]
	,[PrivatePartyDescription]
	,[BanquetContact]
	,[BanquetPhone]
	,[BanquetDescription]
	,[CaterDescription]
	,[Entertainment]
	,coalesce([Logo],'0') as RestaurantLogo
	,coalesce([ImageName],'0') as RestaurantImage
	,[IsActive]
	,[ServerIP]
	,[StaticIPAddress]
	,[ServerPwd]
	,[ERBVersion]
	,[RestStateID]
	,m.[MetroAreaName]
	,r.[IsOptOutForFRNandBackSoon]
	,r.[HasNOFax]
	,r.[IsReachable]
	,r.[Allotment]
	,r.[RestaurantType]
	,r.[TwitterAccountName]
	,r.[FacebookURL]
	,r.[DomainID]
	,d.[PublicSite]
	,d.[PrimaryLanguageID]
	,r.[BrandID]
	,r.[IsOptOutEmailForFRNandBackSoon]
	,r.[LanguageID]
	,l.[LanguageCode]
	,r.HasPrivateParty
	,r.EnablePrivateDining
	,r.PublishPrivateDining
	,r.PrivatePartyContact
	,r.PrivatePartyPhone
	,coalesce(r.LargestCapacity,0) as 'PrivatePartyCapacity'
	,rm.PrivatePartyDescription
	,substring(l.[languageRegionDesc], 0, charindex(' - ', l.[languageRegionDesc])) as Language
	,case when (r.[LanguageID] = d.[PrimaryLanguageID]) then 1 else 0 end as isPrimaryLanguage
	
from	[RestaurantAVW] r

inner join [ERBRestaurant] er
	on	r.[RID] = er.[RID]

inner join [RestaurantMessageAVW] rm 
	on	r.[RID] = rm.[RID]
	and	r.[LanguageID] = rm.[LanguageID]
	
left join RestaurantImage
	on	r.RID = RestaurantImage.RID 

inner join CountryAVW c
	on	c.CountryID = r.Country
	and	c.LanguageID = r.LanguageID

inner join NeighborhoodAVW n
	on	n.NeighborhoodID = r.NeighborhoodID
	and	n.LanguageID = r.LanguageID

inner join MetroAreaAVW m
	on	m.MetroAreaID  = n.MetroAreaID
	and	m.LanguageID = r.LanguageID

inner join Language l 
	on	l.LanguageID = r.LanguageID

inner join Domain d
	on	r.DomainID = d.DomainID

where	r.[RID] = @RID
	and r.[LanguageID] = @LanguageID


-- Food Type for Restaurant
select	fts.foodtypeID	as FoodTypeID
        ,fts.IsPrimary	as IsPrimary
        ,ft.FoodType
from	FoodTypes fts
inner join FoodType ft
	on	fts.foodtypeID  = ft.foodtypeID
where	fts.RID = @RID
	and LanguageID = @LanguageID
order by fts.FTRank


--Offers List for Restaurant
select  Offers.offerID AS OfferID
		,o.Offer
from	Offers
inner join OfferAVW o
	on	Offers.offerID = o.offerID
where  Offers.RID = @RID
	and LanguageID = @LanguageID


--Payment List for Restaurant
select	PaymentTypes.PaymentTypeID AS PaymentTypeID
		,pt.PaymentType
from	PaymentTypes
inner join	PaymentTypeAVW pt
	on	PaymentTypes.PaymentTypeID = pt.PaymentTypeID
where	PaymentTypes.RID = @RID
	and LanguageID = @LanguageID


--get the special events start and end dates
select	MessageTypeID,
		StartDate as SpecialEventStartDate,
		EndDate as SpecialEventEndDate
from	RestaurantCustomMessage rcm
where	rcm.RID = @RID
	and	rcm.LanguageID = @LanguageID
	and	MessageTypeID = 58


--Available languages
select r.[LanguageID]
	,substring(l.[languageRegionDesc], 0, charindex(' - ', l.[languageRegionDesc])) as Language
	,case when (r.[LanguageID] = d.[PrimaryLanguageID]) then 1 else 0 end as isPrimaryLanguage
from	RestaurantAVW r
inner join [RestaurantMessageAVW] rm 
	on	r.[RID] = rm.[RID]
	and	r.[LanguageID] = rm.[LanguageID]
inner join CountryAVW c
	on	c.CountryID = r.Country
	and	c.LanguageID = r.LanguageID
inner join NeighborhoodAVW n
	on	n.NeighborhoodID = r.NeighborhoodID
	and	n.LanguageID = r.LanguageID
inner join MetroAreaAVW m
	on	m.MetroAreaID  = n.MetroAreaID
	and	m.LanguageID = r.LanguageID
inner join	Language l
	on	l.LanguageID = r.LanguageID
inner join	Domain	d
	on	d.DomainID = r.DomainID
where	r.RID = @RID
	and	r.IsActive = 1

GO

GRANT EXECUTE ON [OTR_Restaurant_GetInfo] TO ExecuteOnlyRole

GO

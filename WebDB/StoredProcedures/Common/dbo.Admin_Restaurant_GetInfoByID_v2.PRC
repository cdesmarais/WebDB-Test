
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_GetInfoByID_v2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_GetInfoByID_v2]
GO


create procedure [dbo].[Admin_Restaurant_GetInfoByID_v2]
(
	@RID int
)
as
set NOCOUNT on
set transaction ISOLATION LEVEL read UNCOMMITTED

-- get Confirmation Message Message ID        
declare @Confirmation int              
exec DNGetMessageTypeID 'Confirmation',@Confirmation output    

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
	,coalesce(rcm.Message,dbo.fGetRestaurantMessage(r.RID, @Confirmation)) as ConfirmationMessage
	,[SpecialEvents] as SpecialEvents
	,[MaxAdvanceOptionID] as HowFar
	,[PrivatePartyContact]
	,[StartDate] as SpecialEventStartDate
	,[EndDate] as SpecialEventEndDate
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
	,substring(l.[languageRegionDesc], 0, charindex(' - ', l.[languageRegionDesc])) as Language
	,m.[MetroAreaName]
	,dbo.fGetRestaurantLanguageIDs(@RID) as 'LanguageIDs'
	,r.[IsOptOutForFRNandBackSoon]
	,r.[HasNOFax]
	,r.[IsReachable]
from
	[RestaurantAVW] r

	inner join [ERBRestaurant] er on
	r.[RID] = er.[RID]

	inner join [RestaurantMessageVW] rm on 
	r.[RID] = rm.[RID]

	left join RestaurantCustomMessage rcm  on
	r.RID = rcm.RID and
	r.LanguageID = rcm.LanguageID and
	rcm.MessageTypeID = @Confirmation 

	left join RestaurantImage on
	r.RID = RestaurantImage.RID 

	inner join CountryAVW c on
	c.CountryID = r.Country  and
	c.LanguageID = r.LanguageID  

	inner join Language l on 
	l.LanguageID = r.LanguageID
	
	inner join	dbo.DBUserDistinctLanguageVW db 
	on			db.languageid = r.LanguageID

	inner join NeighborhoodVW n on
	n.NeighborhoodID = r.NeighborhoodID

	inner join MetroAreaVW m on
	m.MetroAreaID  = n.MetroAreaID

where	
	r.[RID] = @RID


-- Food Type for Restaurant
exec Admin_FoodType_ListByRestaurant @RID

--Offers List for Restaurant
exec Admin_Offer_ListByRestaurant @RID

--Payment List for Restaurant
exec Admin_PaymentType_ListByRestaurant @RID

--get the special events start and end dates
exec Admin_Restaurant_GetMessagetStartEndDates @RID

GO

GRANT EXECUTE ON [Admin_Restaurant_GetInfoByID_v2] TO ExecuteOnlyRole

GO


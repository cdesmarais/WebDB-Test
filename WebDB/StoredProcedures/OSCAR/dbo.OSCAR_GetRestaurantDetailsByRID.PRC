

if exists (select * from   dbo.sysobjects where  id = object_id(N'[dbo].[OSCAR_GetRestaurantDetailsByRID]') and OBJECTPROPERTY(id,N'IsProcedure') = 1)
drop procedure [dbo].[OSCAR_GetRestaurantDetailsByRID] 
go

create procedure [dbo].[OSCAR_GetRestaurantDetailsByRID]
(
    @sRIDList varchar(max)
)
as

select
	r.RID
	,r.RName 
	,tzInfo.TZName 
	,r.MappingAddress [Location]
	,r.Address1 
	,r.Address2 
	,r.City 
	,r.State [StateName]
	,r.ZIP 
	,r.Country [CountryName]
	,r.Phone 
	,r.ReservationPhone 
	,r.FaxPhone 
	,r.ExternalURL 
	,r.Email 
	,r.TwitterAccountName 
	,r.FacebookURL 
	,r.RestaurantType
	,uq.GoLiveType
	,uq.GoLiveDtUTC
	,dbo.fTimeConvert(r.CreateDate,4,15) as [TimeStampUTC]
from
	RestaurantVW r
inner join
	dbo.fIDStrToTab(@sRIDList,',') tabRIDs
on r.RID = tabRIDs.Id
left join
	TimeZone tzInfo
on r.TZID = tzInfo.TZID
left join 
	UmamiGoLiveActivationQueue uq
on r.RID = uq.RID

go

grant execute on [OSCAR_GetRestaurantDetailsByRID] to ExecuteOnlyRole

go
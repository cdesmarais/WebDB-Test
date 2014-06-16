


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DFFGetResoData]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DFFGetResoData]
go

/* This procedure gives the reservation information required by DFF Form 
   Content owned by India team,
   please notify asaxena@opentable.com if changing.
*/
create procedure dbo.[DFFGetResoData]
( 
	@ReservationId int
)
as  
begin	
	/* If CallerId is not NULL for the Reservation then 
		1. CustHomeMetroId info is fetched from Caller table otherwise it is fetched from Customer table
		2. User is NOT anonymous user. 
	*/	
	select
	Resid
	,ma.MetroAreaId as MetroID  
	,rest.Country as CountryCode
	,ma.MetroAreaName as MetroName
	,rest.RName AS RestaurantName
	/* -- consumertype will be null only when its an admin reso. In this case, the user is NOT anonymous hence -1 is the default -- */
	,case coalesce(c.ConsumerType,-1) /* if ConsumerType  = 8 then user is anonymous user*/
	   when 8 then 1
	   else 0
	end as IsAnonymous
	,res.ShiftDate as ResDT    
	,res.LanguageID
	,rest.DomainId
	,rest.RID AS WebID   
	/* Shift date is converted UTC as follows. 
	   DST is applied as follows
			  [IsDSTActiveForDateTime] : return 1 if shift date lies in DST for that year else 0
			  if [IsDSTActiveForDateTime] function = 1 for the RealTZId for restaurant 
			  then add offset 60 to GMTTZOffsetMin else only add GMTTZOffsetMin to convert
			  shift date to UTC.
	Also GMTTZOffsetMin is multiplied by -1 as GMTTZOffsetMin offset is added as it is when
	UTC datetime has to be converted to local time zone. Whereas here we need to convert 
	local time zone to UTC.
	*/
	,DateAdd(mi,-1 * (tz.GMTTZOffsetMin + (60 * 
			  dbo.fIsDSTActiveForDateTime(ShiftDate,rest.TZID))),ShiftDate) as ResDTUTC             
	,case when (res.callerid = null)
	   then (select MetroAreaID from customer where custid=res.custid)
	   else (select MetroAreaID from caller where callerid=res.callerid)
	end as CustHomeMetroId
	,res.CustId
	,res.CallerId
	,res.ResTime
from 
	Reservation res     

	left join Customer c 
	on c.custid=res.custid                        

	inner join RestaurantAVW rest  
	on rest.RID = res.RID
	and rest.LanguageID = res.LanguageID

	inner join NeighborhoodAVW n   
	on n.NeighborhoodID = rest.NeighborhoodID 
	and n.LanguageID = res.LanguageID

	inner join MetroAreaAVW ma  
	on ma.MetroAreaID = n.MetroAreaID  
	and ma.LanguageID = res.LanguageID  

	inner join TimeZoneVW tz 
	on tz.TZID = rest.TZID 

where 
	Resid = @ReservationId

end
go

GRANT EXECUTE ON [DFFGetResoData] TO ExecuteOnlyRole

go





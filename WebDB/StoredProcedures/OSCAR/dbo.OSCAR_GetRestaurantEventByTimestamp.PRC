

if exists (select * from   dbo.sysobjects where  id = object_id(N'[dbo].[OSCAR_GetRestaurantEventByTimestamp]') and OBJECTPROPERTY(id,N'IsProcedure') = 1)
drop procedure [dbo].[OSCAR_GetRestaurantEventByTimestamp] 
go

create procedure [dbo].[OSCAR_GetRestaurantEventByTimestamp]
(
    @dtModifiedUTC datetime = null
)
as
/*
Stored procedure used to return list of restaurants which are created post dtModifiedUTC.
If dtModifiedUTC is null then it returns restaurants created in last 6 months.
*/
declare @dtModifiedPST datetime

-- If input dtModifiedUTC is empty then return data for last 6 months 
if @dtModifiedUTC is null
begin
	set @dtModifiedUTC = DATEADD(mm, -6, GETUTCDATE())
end
	
-- Converting input date from UTC to PST which we are using for comparision
set @dtModifiedPST = dbo.fTimeConvert(@dtModifiedUTC, 15, 4)
	
select 
	'CREATED' as [Event]
	,r.RID
	,r.RestaurantType
	,uq.GoLiveType
	,uq.GoLiveDtUTC
	,dbo.fTimeConvert(r.CreateDate,4,15) as [TimeStampUTC] -- Converting CreateDate to UTC
from 
	 RestaurantVW r
	 left join UmamiGoLiveActivationQueue uq
	 on r.RID = uq.RID
where 
	 r.CreateDate > @dtModifiedPST 
order by 
	 r.CreateDate 

go

grant execute on [OSCAR_GetRestaurantEventByTimestamp] to ExecuteOnlyRole

go

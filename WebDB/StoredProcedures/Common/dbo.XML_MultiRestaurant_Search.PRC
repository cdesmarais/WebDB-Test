if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XML_MultiRestaurant_Search]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XML_MultiRestaurant_Search]
GO

CREATE Procedure dbo.XML_MultiRestaurant_Search
 (
  @Restaurants nvarchar(999),
  @ResDateTime datetime,
  @PartySize int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

Declare  @LeadTime		nvarchar(30)
	,@LeadTime_value	int
	,@ServerTZID		int
	,@time_offset		real
	,@time_zone_adjustment	int
	,@min_search_time	datetime
	,@max_search_time	datetime
	,@res_time		datetime
	,@min_advance_res_time	datetime
	,@res_date		datetime
	,@Restaurant_real_time	datetime
	,@issamedayreso		int
	,@weekday		int
	,@RequestedTimePassed	int
	,@daysinadvance		int
	,@rest_time_zone int
,@RestaurantID int

declare  @NoTimesMessage int
		,@DefaultNoTimesMessage nvarchar(255)

exec DNGetMessageTypeID 'NoTimesMessage',@NoTimesMessage output
exec DNGetDefaultMessageFromName 'NoTimesMessage',@DefaultNoTimesMessage output

Declare  
@meal_period as nvarchar(30)
,@SameDayReso as int

--Incentive Checking Begins....
declare  @testDay datetime
 set @res_time = (cast(convert(nvarchar,@ResDateTime,108) as datetime))
 set @min_search_time = dateadd(hour,-2,@res_time)
 set @max_search_time = dateadd(hour,2,@res_time)
 set @testDay = cast(convert(nvarchar,@ResDateTime,110) as datetime)

exec getServerTimeZoneID @retVal = @ServerTZID OUTPUT

 set @LeadTime = '5 minutes'
 set @LeadTime_value = 5

SELECT r.RID AS RestaurantID
,r.RName AS RestaurantName
,er.ServerIP AS NetAddress
,er.serverPwd AS Pwd
,tz._offsetHR AS TimeZoneOffset
,(select _offsetHR from TimeZone where TZID = r.TZID )-(select _offsetHR from TimeZone where TZID = 7) As RealTimeOffset
,moo.MinValue AS MinPartySize
,mxo.MaxValue AS MaxPartySize
,( CASE WHEN (@ResDateTime - dateadd( day,Cast(mao.Days as int),(cast(convert(nvarchar,getDate(),110) as datetime))) > 0) then 1 ELSE 0 END) as tooFarInAdvance
,mao.MaxAdvanceOption AS MaxAdvanceDescription
,r.RName AS R
,r.Allotment as Allotment
,coalesce(@res_date +(select  max(ReservationTemplate.SlotTime)
  			from ScheduleShifts
   			inner join ShiftTemplate 
   			on ScheduleShifts.ShiftTemplateID = ShiftTemplate.ShiftTemplateID
   			and ShiftTemplate.Active = 1
   			and ((ShiftTemplate.CloseTime > @res_time) or (ShiftTemplate.CloseTime > @min_search_time))
   			and ((ShiftTemplate.OpenTime <= @res_time) or (ShiftTemplate.OpenTime < ShiftTemplate.CloseTime))
   			
   			inner join ReservationTemplate 
   			on ReservationTemplate.ShiftTemplateID = ShiftTemplate.ShiftTemplateID
   			
   			where ScheduleShifts.RID = @RestaurantID
			and ScheduleShifts.ShiftID not in (select ShiftID 
			                                             from  SpcBlockedShift 
			                                             where RID = @RestaurantID 
			                                             and cast(convert(nvarchar,assignmentdate,110) as datetime) = @res_date)
  			
  			and scheduleID = coalesce((select scheduleID 
  			                           from SpcSchAssign 
  			                           where SpcSchAssign.RID = r.RID 
  			                           and ShiftTemplate.Active = 1 
  			                           and cast(convert(nvarchar,assignmentdate,110) as datetime) = @res_date),@weekday) 

   			
   			and ReservationTemplate.SizeMin <= @PartySize
   			and ReservationTemplate.SizeMax >= @PartySize
   			and ReservationTemplate.SlotTime >= @min_search_time
  			and ReservationTemplate.SlotTime < @res_time
   			and ShiftTemplate.ResCutOffTime = (case when ((@issamedayreso = 1) AND (ShiftTemplate.CutoffActive = 1) )
									then (Case when (ShiftTemplate.ResCutOffTime >  @Restaurant_real_time)
   										then ShiftTemplate.ResCutOffTime
										else 2 end)
  									else ShiftTemplate.ResCutOffTime end)
   			and (@res_date + ReservationTemplate.SlotTime) >= @min_advance_res_time
 			and ReservationTemplate.SlotID not in (select SlotID 
 			                                                 from TemplateReservation 
 			                                                 inner join Reservation 
 			                                                 on TemplateReservation.ResID = Reservation.ResID 
 			                                                 where TemplateReservation.RID = @RestaurantID 
 			                                                 and TemplateReservation.ShiftDate = @res_date 
 			                                                 and Reservation.RStateID = 1)
			)
  		,0)

    
as F1
,coalesce(@res_date + (select distinct ( ReservationTemplate.SlotTime)
   		from ScheduleShifts
   		inner join ShiftTemplate 
   		on ScheduleShifts.ShiftTemplateID = ShiftTemplate.ShiftTemplateID
   		inner join ReservationTemplate 
   		on ReservationTemplate.ShiftTemplateID = ShiftTemplate.ShiftTemplateID
   		where ScheduleShifts.RID = r.RID
		and ScheduleShifts.ShiftID not in (select ShiftID 
		                                             from  SpcBlockedShift 
		                                             where RID = r.RID 
		                                             and cast(convert(nvarchar,assignmentdate,110) as datetime) = @res_date)
  		and ShiftTemplate.Active = 1
  		and scheduleID = coalesce((select scheduleID 
  			                           from SpcSchAssign 
  			                           where SpcSchAssign.RID = r.RID 
  			                           and ShiftTemplate.Active = 1 
  			                           and cast(convert(nvarchar,assignmentdate,110) as datetime) = @res_date),@weekday) 
   		and ShiftTemplate.CloseTime > @res_time
   		and ShiftTemplate.OpenTime <= @res_time
   		and ReservationTemplate.SlotTime = @res_time
   		and ReservationTemplate.SizeMin <= @PartySize
   		and ReservationTemplate.SizeMax >= @PartySize
   		and ShiftTemplate.ResCutOffTime =
		(case when ((@issamedayreso = 1) AND (ShiftTemplate.CutoffActive = 1) )
		then 
   			Case
			when (ShiftTemplate.ResCutOffTime >  @Restaurant_real_time)
   			then ShiftTemplate.ResCutOffTime
			else 	2 end
 		else 
   			ShiftTemplate.ResCutOffTime
  		end)
   		and (@res_date + ReservationTemplate.SlotTime)  >= @min_advance_res_time
   		and ReservationTemplate.SlotID not in (select SlotID 
   		                                                 from TemplateReservation 
   		                                                 inner join Reservation 
   		                                                 on TemplateReservation.ResID = Reservation.ResID 
   		                                                 where TemplateReservation.RID = r.RID 
   		                                                 and TemplateReservation.ShiftDate = @res_date 
   		                                                 and Reservation.RStateID = 1 )
		),0)

 
as F2
,coalesce(@res_date + (select  min(ReservationTemplate.SlotTime)
   				from ScheduleShifts
   				inner join ShiftTemplate 
   				on ScheduleShifts.ShiftTemplateID = ShiftTemplate.ShiftTemplateID
   				inner join ReservationTemplate 
   				on ReservationTemplate.ShiftTemplateID = ShiftTemplate.ShiftTemplateID
   				where ScheduleShifts.RID = r.RID
				and ScheduleShifts.ShiftID not in (select ShiftID 
				                                             from  SpcBlockedShift 
				                                             where RID = r.RID 
				                                             and cast(convert(nvarchar,assignmentdate,110) as datetime) = @res_date)
  				and ShiftTemplate.Active = 1 
  				and scheduleID = coalesce((select scheduleID 
  			                           from SpcSchAssign 
  			                           where SpcSchAssign.RID = r.RID 
  			                           and ShiftTemplate.Active = 1 
  			                           and cast(convert(nvarchar,assignmentdate,110) as datetime) = @res_date),@weekday) 
   				and ShiftTemplate.CloseTime > @res_time
   				and ((ShiftTemplate.OpenTime <= @res_time) or (ShiftTemplate.OpenTime <= @max_search_time))
   				and ReservationTemplate.SizeMin <= @PartySize
   				and ReservationTemplate.SizeMax >= @PartySize
   				and ReservationTemplate.SlotTime <= @max_search_time
 				and ReservationTemplate.SlotTime >@res_time
   				and ShiftTemplate.ResCutOffTime = (case when ((@issamedayreso = 1) AND (ShiftTemplate.CutoffActive = 1) )
					then case when ShiftTemplate.ResCutOffTime >  @Restaurant_real_time
  						then ShiftTemplate.ResCutOffTime
						else 2 end
  					else ShiftTemplate.ResCutOffTime end)
   				and (@res_date + ReservationTemplate.SlotTime) >= @min_advance_res_time
  				and ReservationTemplate.SlotID not in (select SlotID 
  				                                                 from TemplateReservation 
  				                                                 inner join Reservation 
  				                                                 on TemplateReservation.ResID = Reservation.ResID 
  				                                                 where TemplateReservation.RID = r.RID 
  				                                                 and TemplateReservation.ShiftDate = @res_date 
  				                                                 and Reservation.RStateID = 1 )
				)
  			,0)
 
 as F3
,r.createdate as T1
,r.createdate as T2
,r.createdate AS T3
,r.createdate AS SortOrder
,n.NbhoodName AS NeighborhoodName
,r.PriceQuartileID AS PriceQuartileID
	,(case when r.Allotment = 1 then 0 else coalesce(DTi.IncentiveCount,0) end)  as IncentiveCount
	,(case when r.Allotment = 1 then 0 else coalesce(DTi.exactAmount,0) end) as exactAmount
	,(case when r.Allotment = 1 then 0 else coalesce(DTi.AmountForAll,0)end) as AmountForAll
,r.RName as P1
,r.RName as P2
,r.RName as P3
,r.rankingpoints as I1
,r.rankingpoints as I2
,r.rankingpoints as I3
,@LeadTime as LeadTime

,(CASE  WHEN (dateadd(minute,@LeadTime_value,(dateadd(Hour,( (select _offsetHR from TimeZone   where TZID = r.TZID)-
  (select _offsetHR from TimeZone where TZID = @ServerTZID)),getDate()))) -
  @ResDateTime) < 0 then 1 ELSE 0 END)
  as LeadTime_ok
,(case when (@Restaurant_real_time - coalesce(DTco.CutOff ,cast('11:59 PM' as datetime))) < 0 then 0 else 1 end) as aftercutoff
,Right(cast(DTco.CutOff as nvarchar(20)), 7) as cutoff_time
,coalesce(lower(DTco.Sname), '')as meal_period
,case when rcm.Message is not null then 1 else 0 end as HasNoTimesMessage
,coalesce(rcm.Message,@DefaultNoTimesMessage) as NoTimesMessage
,coalesce(ft.FoodType,'')  as Food_Type	
 ,r.IsReachable as isAvailable

FROM		RestaurantVW r
INNER JOIN	FoodTypes fts
ON		r.RID = fts.RID
inner join	FoodType ft
on		fts.FoodTypeID = ft.FoodTypeID
and		r.LanguageId = ft.LanguageID
and		fts.IsPrimary = 1
INNER JOIN	NeighborhoodAVW n 
ON		r.NeighborhoodID = n.NeighborhoodID 
and		r.LanguageID = n.LanguageID
INNER JOIN	TimeZone tz
ON		r.TZID = tz.TZID 
INNER JOIN	ERBRestaurant er
ON		r.RID = er.RID 
INNER JOIN	MinOnlineOption moo
ON		r.MinOnlineOptionID = moo.MinOnlineOptionID
INNER JOIN	MaxOnlineOption mxo
ON		r.MaxOnlineOptionID = mxo.MaxOnlineOptionID
INNER JOIN	MaxAdvanceOption mao
ON		r.MaxAdvanceOptionID = mao.MaxAdvanceOptionID
LEFT JOIN	RestaurantCustomMessage rcm
ON		r.RID = rcm.RID
and		r.LanguageID = rcm.LanguageID
and		rcm.MessageTypeId = @NoTimesMessage
left join	(select i.RID
		,count(i.incentiveid) 'IncentiveCount'
		,bob2.exactAmount
		,bob.AmountForAll
		from IncentiveVW i
		left join	(select i.RID
					,i.Amount 'exactAmount'
				from IncentiveVW i
				where i.IncentiveDay = @weekday
				and i.Active = 1 
				and i.LastMinutePopThresholdTime IS NULL
				and i.startdate <= @res_date 
				and i.enddate >= @res_date
				and i.starttime <= @res_time
				and i.endtime  > @res_time 
				and i.LastMinutePopThresholdTime IS NULL
				) as bob2
		on i.RID = bob2.RID
		left join	(select  i.RID
					,i.Amount 'AmountForAll'
				from IncentiveVW i
				where  i.IncentiveDay = @weekday
				and i.Active = 1 
				and i.LastMinutePopThresholdTime IS NULL
				and i.startdate <= @res_date
				and i.enddate >= @res_date
				and i.starttime <= @min_search_time  
				and i.endtime  > @max_search_time
				and i.LastMinutePopThresholdTime IS NULL
				) as bob
		on i.RID = bob.RID
		where i.IncentiveDay = @weekday
		and i.Active = 1 
		and i.LastMinutePopThresholdTime IS NULL
		and i.startdate <= @res_date 
		and i.enddate >= @res_date 
		and ((i.starttime <= @res_time  and i.endtime  > @res_time) 
		  or (i.starttime >= @res_time  and i.starttime <= @max_search_time) 
		  or (i.endtime <= @res_time  and i.endtime  > @min_search_time ))
		group by i.RID
		,bob2.exactAmount
		,bob.AmountForAll) as DTi
on r.RID = DTi.RID
left join	(select st.RID
		,st.ResCutOffTime 'CutOff'
		,s.ShiftName 'SName'
		from		shifttemplate st
		inner join	scheduleshifts ss
		on		st.shifttemplateid = ss.shifttemplateid
		and		st.RID = ss.RID
		inner join	shift s
		on		ss.shiftid = s.shiftid
		where		ss.scheduleid =	coalesce((select scheduleid from spcschassign
   						where spcschassign.RID = st.RID and
   						cast(convert(nvarchar, assignmentdate, 110) as datetime) = @res_date),@weekday)
		and		st.shiftid = ss.shiftid
		and		st.Active = 1
		and		st.cutoffActive = 1
		and		st.opentime <= @res_time
		and		st.closetime > @res_time) as DTco
on r.RID = DTco.RID
WHERE		(r.RestStateID = 1)
AND		((LEN(@Restaurants) = 0 OR CHARINDEX(',' + CAST(r.RID AS nvarchar(16))  + ',',',' + @Restaurants + ',') > 0))
AND			r.Allotment <> 1 --** EV: 11/30/2009: Never allow allotment / console in legacy APIs
GO

GRANT EXECUTE ON [XML_MultiRestaurant_Search] TO ExecuteOnlyRole

GO

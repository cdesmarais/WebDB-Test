if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_ListFavorites]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_ListFavorites]
GO

CREATE Procedure dbo.Restaurant_ListFavorites
 (
  @GeoID int,
  @UserID int,
  @ResDateTime datetime,
  @PartySize int,
  @IsCaller int = 0
 )
As

set transaction isolation level read uncommitted
SET NOCOUNT ON


Declare  @LeadTime		nvarchar(30)
	,@LeadTime_value	int
	,@ServerTZID		int
	,@time_offset		real
	,@time_zone_adjustment	numeric
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

	
select   @LeadTime            = '30 minutes'
        ,@LeadTime_value      = 30

exec getServerTimeZoneID @retVal = @ServerTZID OUTPUT

set @rest_time_zone =  (select TZID from MetroArea where MetroAreaID =  @GeoID)
set @time_zone_adjustment = ((select _offsetHR from TimeZone where  TZID = @rest_time_zone)- (select _offsetHR from TimeZone where TZID = @ServerTZID))

select   @min_search_time	= dateadd(hour,-2,(cast(convert(nvarchar,@ResDateTime,108)as datetime)))
        ,@max_search_time	= dateadd(hour, 2,(cast(convert(nvarchar,@ResDateTime,108)as datetime)))
        ,@res_time		= cast(convert(nvarchar,@ResDateTime,108) as datetime)
        ,@weekday		= datepart(dw,@ResDateTime)
        ,@min_advance_res_time	= dateadd (mi,@LeadTime_value,(dateadd(Hour,@time_zone_adjustment,getDate())))
        ,@res_date		= cast(convert(nvarchar, @ResDateTime, 110) as datetime)
        ,@Restaurant_real_time	= cast(convert(nvarchar,(dateadd(Hour,@time_zone_adjustment,getDate())),108) as datetime)
        ,@issamedayreso		= (case when (@res_date = cast(CONVERT(nvarchar,(dateadd(Hour,@time_zone_adjustment,getDate())),110) as datetime)) then 1 else 0 end)
        ,@daysinadvance		= datediff(day,getdate(),@ResDateTime)

declare @NoTimesMessage int,@DefaultNoTimesMessage nvarchar(255)
exec DNGetMessageTypeID 'NoTimesMessage',@NoTimesMessage output
exec DNGetDefaultMessageFromName 'NoTimesMessage',@DefaultNoTimesMessage output
if @IsCaller = 0
BEGIN

SELECT DISTINCT
	r.RID as RestaurantID
	,r.RName as RestaurantName
	,er.ServerIP as NetAddress
	,er.serverPwd as Password
     	,(Case when er.FixedTimeOffset = 1 then -8
	else tz._offsetHR END) AS TimeZoneOffset
     	,moo.MinValue as MinPartySize
     	,mxo.MaxValue as MaxPartySize
	,(CASE WHEN(@ResDateTime - dateadd( day,Cast(mao.Days as int),(cast(convert(nvarchar,getDate(),110) as datetime))) > 0) then 1 ELSE 0 END) as TooFarInAdvance
     	,mao.MaxAdvanceOption as MaxAdvanceDescription
     	,r.RName as R 
 	,r.Allotment as Allotment
,(Case  When r.Allotment = 1 
           then coalesce(@res_date +(select  max(ReservationTemplate.SlotTime)
  			from ScheduleShifts
   			inner join ShiftTemplate 
   			on ScheduleShifts.ShiftTemplateID = ShiftTemplate.ShiftTemplateID
   			and ShiftTemplate.Active = 1
   			and ((ShiftTemplate.CloseTime > @res_time) or (ShiftTemplate.CloseTime > @min_search_time))
   			and ((ShiftTemplate.OpenTime <= @res_time) or (ShiftTemplate.OpenTime < ShiftTemplate.CloseTime))
   			inner join ReservationTemplate 
   			on ReservationTemplate.ShiftTemplateID = ShiftTemplate.ShiftTemplateID
   			where ScheduleShifts.RID = r.RID
			and ScheduleShifts.ShiftID not in (select ShiftID 
			                                             from  SpcBlockedShift 
			                                             where RID = r.RID 
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
 			                                                 where TemplateReservation.RID = r.RID 
 			                                                 and TemplateReservation.ShiftDate = @res_date 
 			                                                 and Reservation.RStateID = 1)
			),0)
  	else r.CreateDate
     end)
as F1
,(Case  When r.Allotment = 1 then
      	(coalesce(@res_date + (select distinct ( ReservationTemplate.SlotTime)
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
		),0)) else
	r.CreateDate
 end)  as F2
,(Case
	When 	r.Allotment = 1
	then	(coalesce(@res_date + (select  min(ReservationTemplate.SlotTime)
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
				),0))
  else r.CreateDate
  end)
 as F3
 ,r.CreateDate as T1
 ,r.CreateDate as T2
 ,r.CreateDate as T3
 ,@time_zone_adjustment as RealTimeOffset
 ,n.NbhoodName as NeighborhoodName
 ,r.PriceQuartileID as Price_Quartile_ID
	,(case when r.Allotment = 1 then 0 else coalesce(DTi.IncentiveCount,0) end)  as IncentiveCount
	,(case when r.Allotment = 1 then 0 else coalesce(DTi.exactAmount,0) end) as exactAmount
	,(case when r.Allotment = 1 then 0 else coalesce(DTi.AmountForAll,0)end) as AmountForAll
	,r.RName as P1
	,r.RName as P2
	,r.RName as P3
	,r.RankingPoints as I1
	,r.RankingPoints as I2
	,r.RankingPoints as I3
	,@LeadTime as lead_time
,(CASE  WHEN (dateadd(minute,@LeadTime_value,@Restaurant_real_time) -  	@ResDateTime) < 0 then 1 ELSE 0 END) as lead_time_ok
	,(case when (@Restaurant_real_time - coalesce(DTco.CutOff ,cast('11:59 PM' as datetime))) < 0 then 0 else 1 end) as aftercutoff
	,Right(cast(DTco.CutOff as nvarchar(20)), 7) as cutoff_time 
	,@issamedayreso as samedayreso	
	,coalesce(lower(DTco.Sname), '')as meal_period
	,r.TZID as TimesReturned
	,0 as NextAvailable
	,case when rcm.Message is not null then 1 else 0 end as HasNoTimesMessage
,dbo.fGetRestaurantMessage(r.RID, @NoTimesMessage)  as NoTimesMessage
,(case r.Allotment when 1 then 1 else r.IsReachable end) as IsReachable
,coalesce(ft.FoodType,'')  as FoodType	
,coalesce(bd.message,'') as BlockedDayMessage

FROM RestaurantVW r
INNER JOIN	FoodTypes fts
ON		r.RID = fts.RID
inner join	FoodType ft
on		fts.FoodTypeID = ft.FoodTypeID
and		ft.LanguageID = r.LanguageID
and		fts.IsPrimary = 1
INNER JOIN	Favorites 
ON		r.RID = Favorites.RID
INNER JOIN	NeighborhoodAVW n 
ON		r.NeighborhoodID = n.NeighborhoodID
and		r.LanguageID = n.LanguageID
INNER JOIN	ERBRestaurant er
ON		r.RID = er.RID
INNER JOIN	TimeZone tz
ON		r.TZID = tz.TZID
INNER JOIN	MinOnlineOption moo
ON		r.MinOnlineOptionID = moo.MinOnlineOptionID
INNER JOIN	MaxOnlineOption mxo
ON		r.MaxLargePartyID = mxo.MaxOnlineOptionID
INNER JOIN	MaxAdvanceOption mao
ON		r.MaxAdvanceOptionID = mao.MaxAdvanceOptionID
LEFT JOIN 	BlockedDayVW bd 
ON 		bd.rid=r.rid and bd.blockeddate=@res_date and bd.blockeddate >= getdate()
LEFT JOIN	RestaurantCustomMessage rcm
ON		r.RID = rcm.RID
and		r.LanguageID = rcm.LanguageID
and rcm.MessageTypeId = @NoTimesMessage
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
WHERE (n.MetroAreaID = @GeoID)
AND @UserID = Favorites.CustID
AND (r.RestStateID = 1)
AND ((r.IsReachable = 1) or (r.Allotment = 1 and r.RestStateID = 1))

Return(0)

END

if @IsCaller <> 0 -- this is a Caller reso so inner join on caller_favorites not Favorites....
BEGIN


SELECT DISTINCT
	r.RID as RestaurantID
	,r.RName as RestaurantName
	,er.ServerIP as NetAddress
	,er.serverPwd as Password
     	,(Case when er.FixedTimeOffset = 1 then -8 else tz._offsetHR END) AS TimeZoneOffset
     	,moo.MinValue as MinPartySize
     	,mxo.MaxValue as MaxPartySize
	,(CASE WHEN(@ResDateTime - dateadd( day,Cast(mao.Days as int),(cast(convert(nvarchar,getDate(),110) as datetime))) > 0) then 1 ELSE 0 END) as TooFarInAdvance
     	,mao.MaxAdvanceOption as MaxAdvanceDescription
     	,r.RName as R
     	,r.Allotment as Allotment   
     	,(Case  When r.Allotment = 1 then
 	coalesce(@res_date +(select  max(ReservationTemplate.SlotTime)
  			from ScheduleShifts
   			inner join ShiftTemplate 
   			on ScheduleShifts.ShiftTemplateID = ShiftTemplate.ShiftTemplateID
   			and ShiftTemplate.Active = 1
   			and ((ShiftTemplate.CloseTime > @res_time) or (ShiftTemplate.CloseTime > @min_search_time))
   			and ((ShiftTemplate.OpenTime <= @res_time) or (ShiftTemplate.OpenTime < ShiftTemplate.CloseTime))
   			
   			inner join ReservationTemplate 
   			on ReservationTemplate.ShiftTemplateID = ShiftTemplate.ShiftTemplateID
   			
   			where ScheduleShifts.RID = r.RID
			and ScheduleShifts.ShiftID not in (select ShiftID 
			                                             from  SpcBlockedShift 
			                                             where RID = r.RID 
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
 			                                                 where TemplateReservation.RID = r.RID 
 			                                                 and TemplateReservation.ShiftDate = @res_date 
 			                                                 and Reservation.RStateID = 1)
			),0)
  	else r.CreateDate
     end)
as F1
,(Case  When r.Allotment = 1 then
      	(coalesce(@res_date + (select distinct ( ReservationTemplate.SlotTime)
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
		),0))
 else
	r.CreateDate
 end)  as F2
,(Case
	When 	r.Allotment = 1
	then	(coalesce(@res_date + (select  min(ReservationTemplate.SlotTime)
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
   				and ShiftTemplate.ResCutOffTime = (case when ((@issamedayreso = 1) AND (ShiftTemplate.CutoffActive = 1))
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
				),0))
  else r.CreateDate
  end)
 as F3
 ,r.CreateDate as T1
 ,r.CreateDate as T2
 ,r.CreateDate as T3
 ,@time_zone_adjustment as RealTimeOffset
 ,n.NbhoodName as NeighborhoodName
 ,r.PriceQuartileID
as Price_Quartile_ID	
,(case when r.Allotment = 1 then 0 else coalesce(DTi.IncentiveCount,0) end)  as IncentiveCount
	,(case when r.Allotment = 1 then 0 else coalesce(DTi.exactAmount,0) end) as exactAmount
	,(case when r.Allotment = 1 then 0 else coalesce(DTi.AmountForAll,0)end) as AmountForAll
	,r.RName as P1
	,r.RName as P2
	,r.RName as P3
	,r.RankingPoints as I1
	,r.RankingPoints as I2
	,r.RankingPoints as I3
	,@LeadTime as lead_time
	,(CASE  WHEN (dateadd(minute,@LeadTime_value,@Restaurant_real_time) - @ResDateTime) < 0 then 1 ELSE 0 END) as lead_time_ok
	,(case when (@Restaurant_real_time - coalesce(DTco.CutOff ,cast('11:59 PM' as datetime))) < 0 then 0 else 1 end) as AfterCutoff
	,Right(cast(DTco.CutOff as nvarchar(20)), 7) as cutoff_time 
,@issamedayreso as samedayreso	
,coalesce(lower(DTco.Sname), '')as meal_period
,r.TZID as TimesReturned
,0 as NextAvailable
	,case when rcm.Message is not null then 1 else 0 end as HasNoTimesMessage
,dbo.fGetRestaurantMessage(r.RID, @NoTimesMessage)  as NoTimesMessage
,(case 	r.Allotment when 1 then 1 else r.IsReachable end) as IsReachable	
,coalesce(ft.FoodType,'')  as FoodType
,@LeadTime_value as lead_time_value

--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
FROM RestaurantVW r
INNER JOIN	FoodTypes fts
ON		r.RID = fts.RID
inner join	FoodType ft
on		fts.FoodTypeID = ft.FoodTypeID
and		r.LanguageID = ft.LAnguageID
and		fts.IsPrimary = 1
INNER JOIN	CallerRestaurants cr 
ON		r.RID = cr.RID
INNER JOIN	NeighborhoodAVW n 
ON		r.NeighborhoodID = n.NeighborhoodID
and		r.LanguageID = n.LanguageID
INNER JOIN	ERBRestaurant er 
ON		r.RID = er.RID
INNER JOIN	TimeZone tz
ON		r.TZID = tz.TZID
INNER JOIN	MinOnlineOption moo
ON		r.MinOnlineOptionID = moo.MinOnlineOptionID
INNER JOIN	MaxOnlineOption mxo 
ON		r.MaxLargePartyID = mxo.MaxOnlineOptionID
INNER JOIN	MaxAdvanceOption mao
ON		r.MaxAdvanceOptionID = mao.MaxAdvanceOptionID
LEFT JOIN	RestaurantCustomMessage rcm
ON		r.RID = rcm.RID
and		r.LanguageID = rcm.LanguageID
and rcm.MessageTypeId = @NoTimesMessage
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
WHERE (n.MetroAreaID = @GeoID)
AND (cr.CallerID = @UserID)
AND (r.RestStateID = 1)
AND ((r.IsReachable = 1) or (r.Allotment = 1 and r.RestStateID = 1))
AND			r.Allotment <> 1 --** EV: 11/30/2009: Never allow allotment / console in legacy APIs

Return(1)

END

GO

GRANT EXECUTE ON [Restaurant_ListFavorites] TO ExecuteOnlyRole

GO

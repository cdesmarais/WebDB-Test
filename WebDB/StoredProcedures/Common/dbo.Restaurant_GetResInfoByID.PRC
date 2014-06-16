if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_GetResInfoByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_GetResInfoByID]
GO

CREATE Procedure dbo.Restaurant_GetResInfoByID
 (
  @RestaurantID int,
  @ResDateTime datetime,
  @PartySize int
 )
As

set transaction isolation level read uncommitted
SET NOCOUNT ON

Declare  @LeadTime as nvarchar(30) 
		,@LeadTime_value as int
		,@ServerTZID as int
		,@time_offset real

 set @LeadTime = '5 minutes'  
 set @LeadTime_value = 5
 exec getServerTimeZoneID @retVal = @ServerTZID OUTPUT

declare  @rest_time_zone int
		,@MetroAreaID int
		,@time_zone_adjustment numeric
		
select @MetroAreaID = MetroAreaID from Neighborhood n where NeighborhoodID =  (select NeighborhoodID from Restaurant where RID = @RestaurantID)
set @rest_time_zone =    (select TZID from MetroArea where MetroAreaID = @MetroAreaID)
set @time_zone_adjustment = ( (select _offsetHR from TimeZone where  TZID = @rest_time_zone)- (select _offsetHR from TimeZone where TZID = @ServerTZID))

declare  @min_search_time datetime
		,@max_search_time datetime
		,@res_time datetime
		
set @min_search_time =   dateadd(hour,-2,(cast(convert(nvarchar,@ResDateTime,108)as datetime)))
set @max_search_time =   dateadd(hour,2,(cast(convert(nvarchar,@ResDateTime,108)as datetime))) --Warning: this will not span days!
set @res_time =  cast(convert(nvarchar,@ResDateTime,108) as datetime)

declare  @min_advance_res_time datetime
		,@res_date datetime
		,@restaurant_real_time datetime
		,@issamedayreso int
		,@weekday int
		
set @weekday = datepart(dw,@ResDateTime)
set @min_advance_res_time =    dateadd (mi,@LeadTime_value,(dateadd(Hour,@time_zone_adjustment,getDate()) ) )
set @res_date =  cast(convert(nvarchar,@ResDateTime,110) as datetime)
set @restaurant_real_time = cast(convert(nvarchar ,(dateadd(Hour,@time_zone_adjustment,getDate())),108) as datetime)
set @issamedayreso = (case when (@res_date = cast(CONVERT(nvarchar,(dateadd(Hour,@time_zone_adjustment,getDate())),110) as datetime)) then 1 else 0 end)


declare  @NoTimesMessage int
		,@DefaultNoTimesMessage nvarchar(500)

--exec DNGetMessageTypeID 'NoTimesMessage',@NoTimesMessage output
--exec DNGetDefaultMessageFromName 'NoTimesMessage',@DefaultNoTimesMessage output
--exec DNGetRestaurantMessage @RestaurantID, @NoTimesMessage,@DefaultNoTimesMessage output


SELECT  distinct r.RID AS RestaurantID,
     r.RName AS RestaurantName,
     @MetroAreaID as MetroAreaID,
    er.ServerIP AS NetAddress,
     er.serverPwd as Password,

     (Case when er.FixedTimeOffset = 1 then -8
	else tz._offsetHR END) AS TimeZoneOffset,
     moo.MinValue AS MinPartySize,
    (case when r.AcceptLargeParty = 0 then mxo2.MaxValue else mxo.MaxValue end) AS MaxPartySize,
     ( CASE
     WHEN 	(@ResDateTime - dateadd( day,Cast(mao.Days as int),
 		(cast(convert(nvarchar,getDate(),110) as datetime))) > 0) then 1--too far in advance
     ELSE 	0
     END) as tooFarInAdvance,
     mao.Days AS MaxAdvance,
     mao.MaxAdvanceOPtion AS MaxAdvanceDescription,
     r.RName AS R
     ,r.Allotment as Allotment
,coalesce(@res_date +(select  max(ReservationTemplate.SlotTime)
  			from ScheduleShifts
   			inner join ShiftTemplate 
   			on ScheduleShifts.ShiftTemplateID = ShiftTemplate.ShiftTemplateID
   			and ShiftTemplate.active = 1
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
  			                           and ShiftTemplate.active = 1 
  			                           and cast(convert(nvarchar,assignmentdate,110) as datetime) = @res_date),@weekday) 

   			
   			and ReservationTemplate.SizeMin <= @PartySize
   			and ReservationTemplate.SizeMax >= @PartySize
   			and ReservationTemplate.SlotTime >= @min_search_time
  			and ReservationTemplate.SlotTime < @res_time
   			and ShiftTemplate.ResCutOffTime = (case when ((@issamedayreso = 1) AND (ShiftTemplate.CutoffActive = 1) )
									then (Case when (ShiftTemplate.ResCutOffTime >  @restaurant_real_time)
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
  		and ShiftTemplate.active = 1
  		and scheduleID = coalesce((select scheduleID 
  			                           from SpcSchAssign 
  			                           where SpcSchAssign.RID = r.RID 
  			                           and ShiftTemplate.active = 1 
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
			when (ShiftTemplate.ResCutOffTime >  @restaurant_real_time)
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
  				and ShiftTemplate.active = 1 
  				and scheduleID = coalesce((select scheduleID 
  			                           from SpcSchAssign 
  			                           where SpcSchAssign.RID = r.RID 
  			                           and ShiftTemplate.active = 1 
  			                           and cast(convert(nvarchar,assignmentdate,110) as datetime) = @res_date),@weekday) 
   				and ShiftTemplate.CloseTime > @res_time
   				and ((ShiftTemplate.OpenTime <= @res_time) or (ShiftTemplate.OpenTime <= @max_search_time))
   				and ReservationTemplate.SizeMin <= @PartySize
   				and ReservationTemplate.SizeMax >= @PartySize
   				and ReservationTemplate.SlotTime <= @max_search_time
 				and ReservationTemplate.SlotTime >@res_time
   				and ShiftTemplate.ResCutOffTime = (case when ((@issamedayreso = 1) AND (ShiftTemplate.CutoffActive = 1) )
					then case when ShiftTemplate.ResCutOffTime >  @restaurant_real_time
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
 ,r.CreateDate as T1
 ,r.CreateDate as T2
 ,r.CreateDate as T3
 ,@time_zone_adjustment as RealTimeOffset
 ,n.NbhoodName as NeighborhoodName
 ,r.PriceQuartileID as Price_Quartile_ID	
,(case when r.allotment = 1 then 0 else coalesce(DTi.IncentiveCount,0) end)  as IncentiveCount
,(case when r.allotment = 1 then 0 else coalesce(DTi.exactAmount,0) end) as exactAmount
,(case when r.allotment = 1 then 0 else coalesce(DTi.AmountForAll,0)end) as AmountForAll
,r.RName as P1
,r.RName as P2
,r.RName as P3
,r.RankingPoints as I1
,r.RankingPoints as I2
,r.RankingPoints as I3
,@LeadTime as lead_time
,@restaurant_real_time as real_time_at_restaurant 
,(CASE  WHEN (dateadd(minute,@LeadTime_value,@restaurant_real_time) - @ResDateTime) < 0 then 1 ELSE 0 END) as lead_time_ok	
,(case when (@restaurant_real_time - coalesce(DTco.CutOff ,cast('11:59 PM' as datetime))) < 0 then 0 else 1 end) as AfterCutoff
,Right(cast(DTco.CutOff as nvarchar(20)), 7) as cutoff_time 
,@issamedayreso as samedayreso	
,coalesce(lower(DTco.Sname), '')as meal_period
,r.TZID as TimesReturned
,(case when er.ProductID >= 6 then 1 else 0 end) as NextAvailable
,case when rcm.Message is not null then 1 else 0 end as HasNoTimesMessage
,coalesce(rcm.Message,(r.RName+' has no tables available for the partysize, date and time requested.')) as NoTimesMessage
,(case 	r.allotment when 1 then 1 else r.IsReachable end) as IsReachable 
,coalesce(ft.FoodType,'')  as food_type	
,@LeadTime_value as lead_time_value
,1 as Searchable
,ProductID as Product_ID
,ProductID as SearchStatus
,coalesce(bd.message,'') as BlockedDayMessage

FROM		RestaurantVW r
INNER JOIN	FoodTypes fts
ON		r.RID = fts.RID
and			fts.IsPrimary = 1
inner join	FoodType ft
on			ft.FoodTypeID = fts.FoodTypeID
and			ft.LanguageID = r.LanguageID
INNER JOIN	NeighborhoodAVW n 
ON			n.NeighborhoodID = r.NeighborhoodID
and			n.LanguageID = r.LanguageID
INNER JOIN	ERBRestaurant er 
ON		r.RID = er.RID
INNER JOIN	TimeZone tz 
ON		r.TZID = tz.TZID
INNER JOIN	MinOnlineOption moo 
ON		r.MinOnlineOptionID = moo.MinOnlineOptionID
INNER JOIN	MaxOnlineOption mxo 
ON		r.MaxLargePartyID = mxo.MaxOnlineOptionID
INNER JOIN	MaxOnlineOption mxo2  -- used for AcceptLargeParty = 0
ON		r.MaxOnlineOptionID = mxo2.MaxOnlineOptionID
INNER JOIN	MaxAdvanceOption mao 
ON		r.MaxAdvanceOptionID = mao.MaxAdvanceOptionID
LEFT JOIN 	BlockedDayVW bd 
ON 		bd.rid=r.rid and bd.blockeddate=@res_date and bd.blockeddate >= getdate()
left JOIN	RestaurantCustomMessage rcm
ON			r.RID = rcm.RID
and			r.LanguageID = rcm.LanguageID
and			rcm.MessageTypeId = @NoTimesMessage
left join	(select i.RID
		,count(i.incentiveid) 'IncentiveCount'
		,bob2.exactAmount
		,bob.AmountForAll
		from IncentiveVW i
		left join	(select i.RID
					,i.Amount 'exactAmount'
				from IncentiveVW i
				where i.IncentiveDay = @weekday
				and i.LastMinutePopThresholdTime IS NULL
				and i.active = 1 
				and i.startdate <= @res_date 
				and i.enddate >= @res_date
				and i.starttime <= @res_time
				and i.endtime  > @res_time 
				) as bob2
		on i.RID = bob2.RID
		left join	(select  i.RID
					,i.Amount 'AmountForAll'
				from IncentiveVW i
				where  i.IncentiveDay = @weekday
				and i.LastMinutePopThresholdTime IS NULL
				and i.active = 1 
				and i.startdate <= @res_date
				and i.enddate >= @res_date
				and i.starttime <= @min_search_time  
				and i.endtime  > @max_search_time
				) as bob
		on i.RID = bob.RID
		where i.IncentiveDay = @weekday
		and i.active = 1 
		and i.startdate <= @res_date 
		and i.enddate >= @res_date 
		and ((i.starttime <= @res_time  and i.endtime  > @res_time) 
		  or (i.starttime >= @res_time  and i.starttime <= @max_search_time) 
		  or (i.endtime <= @res_time  and i.endtime  > @min_search_time ))
		and i.LastMinutePopThresholdTime IS NULL
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
		and		st.active = 1
		and		st.cutoffactive = 1
		and		st.opentime <= @res_time
		and		st.closetime > @res_time) as DTco
on r.RID = DTco.RID
WHERE r.RID = @RestaurantID
and (r.RestStateID = 1) 
		and  (r.Allotment = 1 
		or r.IsReachable = 1)

GO


GRANT EXECUTE ON [Restaurant_GetResInfoByID] TO ExecuteOnlyRole

GO

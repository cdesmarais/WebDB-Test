if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_ListByFoodTypesPricesAndMacroNeighborhoods]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_ListByFoodTypesPricesAndMacroNeighborhoods]
GO


CREATE Procedure dbo.Restaurant_ListByFoodTypesPricesAndMacroNeighborhoods
 (
  @GeoID              int
 ,@FoodTypes          nvarchar(999)
 ,@MacroNeighborhoods nvarchar(999)
 ,@PriceRange         nvarchar(255)
 ,@ResDateTime        datetime
 ,@PartySize          int
 )

As

set transaction isolation level read uncommitted
SET NOCOUNT ON

Declare  @lead_time             nvarchar(30)
        ,@lead_time_value       int
        ,@ServerTimeZoneID      int
        ,@rest_TimeZone         int
        ,@TimeZone_adjustment   numeric
        ,@min_search_time       datetime
        ,@max_search_time       datetime
        ,@res_time              datetime
        ,@min_advance_res_time  datetime
        ,@res_date              datetime
        ,@restaurant_real_time  datetime
        ,@issamedayreso         int
        ,@weekday               int
        ,@NoTimesMessage        int
        ,@DefaultNoTimesMessage nvarchar(500)

select   @lead_time            = '5 minutes'
        ,@lead_time_value      = 5

exec getServerTimeZoneID @ServerTimeZoneID OUTPUT


set @rest_TimeZone       = (select TZID from MetroArea where MetroAreaID = @GeoID)
set @TimeZone_adjustment = ((select _offsetHR from TimeZone where  TZID = @rest_TimeZone)- (select _offsetHR from TimeZone where TZID = @ServerTimeZoneID))

select   @min_search_time      = dateadd(hour,-2,(cast(convert(nvarchar,@ResDateTime,108)as datetime)))
        ,@max_search_time      = dateadd(hour, 2,(cast(convert(nvarchar,@ResDateTime,108)as datetime)))
        ,@res_time             = cast(convert(nvarchar,@ResDateTime,108) as datetime)
        ,@weekday              = datepart(dw,@ResDateTime)
        ,@min_advance_res_time = dateadd (mi,30,(dateadd(Hour,@TimeZone_adjustment,getDate())))
        ,@res_date             = cast(convert(nvarchar, @ResDateTime, 110) as datetime)
        ,@restaurant_real_time = cast(convert(nvarchar,(dateadd(Hour,@TimeZone_adjustment,getDate())),108) as datetime)
        ,@issamedayreso        = (case when (@res_date = cast(CONVERT(nvarchar,(dateadd(Hour,@TimeZone_adjustment,getDate())),110) as datetime)) then 1 else 0 end)

select   @FoodTypes          = coalesce (@FoodTypes, '')
        ,@MacroNeighborhoods = coalesce (@MacroNeighborhoods, '')
        ,@PriceRange         = coalesce (@PriceRange, '')

--exec DNGetMessageTypeID 'NoTimesMessage',@NoTimesMessage output
--exec DNGetDefaultMessageFromName 'NoTimesMessage',@DefaultNoTimesMessage output

SELECT DISTINCT r.RID AS RestaurantID
		,r.RName AS RestaurantName
		,er.ServerIP AS NetAddress
		,er.ServerPwd AS Password
		,(Case when er.FixedTimeOffset = 1 then -8 else tz._offsetHR END) AS TimeZoneOffset
		,moo.MinValue AS MinPartySize
		,(case when r.AcceptLargeParty = 0 then mxo2.MaxValue else mxo.MaxValue end) AS MaxPartySize
		,(CASE WHEN (@ResDateTime - dateadd( day, Cast(mao.Days as int)
		,(cast(convert(nvarchar, getDate(), 110) as datetime))) > 0) then 1 ELSE	0 END) as tooFarInAdvance
		,mao.MaxAdvanceOption AS MaxAdvanceDescription
		,r.RName AS R
		,r.Allotment as Allotment

		,(Case  When r.Allotment = 1 then
		coalesce(@res_date +
	(select  max(ReservationTemplate.SlotTime)
	from ScheduleShifts
	inner join ShiftTemplate on
	ScheduleShifts.ShiftTemplateID = ShiftTemplate.ShiftTemplateID
	inner join ReservationTemplate on
	ReservationTemplate.ShiftTemplateID = ShiftTemplate.ShiftTemplateID
	where ScheduleShifts.RID = r.RID
	and ShiftTemplate.Active = 1 
	and ScheduleID = coalesce((select ScheduleID from SpcSchAssign
	where SpcSchAssign.RID = r.RID
	and cast(convert(nvarchar, AssignmentDate, 110) as datetime) = @res_date),@weekday)
	and ((ShiftTemplate.CloseTime > @res_time and ShiftTemplate.OpenTime <= @res_time )
	or (ShiftTemplate.CloseTime > @min_search_time and ShiftTemplate.OpenTime < ShiftTemplate.CloseTime))
	and ReservationTemplate.SizeMin <= @PartySize
	and ReservationTemplate.SizeMax >= @PartySize
	and ReservationTemplate.SlotTime >=  @min_search_time
	and ReservationTemplate.SlotTime < @res_time
	and ShiftTemplate.ResCutoffTime = (case when ((@issamedayreso = 1) AND (ShiftTemplate.CutoffActive = 1) )
	then 
	(Case
	when  
	(ShiftTemplate.ResCutoffTime >@restaurant_real_time)
	then 	ShiftTemplate.ResCutoffTime
	else 	2
	end)
	else   ShiftTemplate.ResCutoffTime 
	end)

	and (@res_date + ReservationTemplate.SlotTime) >= @min_advance_res_time
	and ReservationTemplate.SlotID not in
	(select SlotID from TemplateReservation
	inner join reservation on
	TemplateReservation.ResID = reservation.ResID where
	TemplateReservation.RID = r.RID
	and TemplateReservation.ShiftDate = @res_date
	and reservation.RStateID = 1 )
	), 0) else r.CreateDate  end) as F1

 ,(Case  When r.Allotment = 1 then
      	coalesce(
		@res_date +
  		(select distinct ( ReservationTemplate.SlotTime)
   		from ScheduleShifts
   		inner join ShiftTemplate on
   		ScheduleShifts.ShiftTemplateID = ShiftTemplate.ShiftTemplateID
   		inner join ReservationTemplate on
   		ReservationTemplate.ShiftTemplateID = ShiftTemplate.ShiftTemplateID
   		where ScheduleShifts.RID = r.RID
 		and ShiftTemplate.Active = 1
  		and ScheduleID = coalesce(
			(select ScheduleID from SpcSchAssign
 			where SpcSchAssign.RID = r.RID and
  			cast(convert(nvarchar, AssignmentDate, 110) as datetime) = @res_date),@weekday)
 		and ShiftTemplate.CloseTime > @res_time
   		and ShiftTemplate.OpenTime <= @res_time
   		and ReservationTemplate.SlotTime = @res_time
   		and ReservationTemplate.SizeMin <= @PartySize
   		and ReservationTemplate.SizeMax >= @PartySize
   		and ShiftTemplate.ResCutoffTime =
			(case
			when ((@issamedayreso = 1) AND (ShiftTemplate.CutoffActive = 1) )
			then Case when  (ShiftTemplate.ResCutoffTime > @restaurant_real_time)
   				then 	ShiftTemplate.ResCutoffTime
				else 	2 end
			else  ShiftTemplate.ResCutoffTime
  			end)
   		and (@res_date + ReservationTemplate.SlotTime)  >= @min_advance_res_time
   		and ReservationTemplate.SlotID not in
   			(select SlotID from TemplateReservation
    			inner join reservation on
    			TemplateReservation.ResID = reservation.ResID where
    			TemplateReservation.RID = r.RID
     			and TemplateReservation.ShiftDate = @res_date
     			and reservation.RStateID = 1 )
		), 0) else r.CreateDate end) as F2
		
 ,(Case When r.Allotment = 1
	then coalesce (
  				@res_date + (select  min(ReservationTemplate.SlotTime)
   				from ScheduleShifts
   				inner join ShiftTemplate on
   				ScheduleShifts.ShiftTemplateID = ShiftTemplate.ShiftTemplateID
   				inner join ReservationTemplate on
   				ReservationTemplate.ShiftTemplateID = ShiftTemplate.ShiftTemplateID
   				where ScheduleShifts.RID = r.RID
  				and ShiftTemplate.Active = 1   
  				and ScheduleID = coalesce((select ScheduleID from SpcSchAssign 				where SpcSchAssign.RID = r.RID and
  				cast(convert(nvarchar, AssignmentDate, 110) as datetime) = @res_date),@weekday)
and ((ShiftTemplate.CloseTime > @res_time and ShiftTemplate.OpenTime <= @max_search_time )
or (ShiftTemplate.CloseTime <= @res_time and ShiftTemplate.OpenTime > ShiftTemplate.OpenTime))


   				and ReservationTemplate.SizeMin <= @PartySize
   				and ReservationTemplate.SizeMax >= @PartySize
   				and ReservationTemplate.SlotTime <= @max_search_time
   				and ReservationTemplate.SlotTime > @res_time
   				and ShiftTemplate.ResCutoffTime = (case when ((@issamedayreso = 1) AND (ShiftTemplate.CutoffActive = 1) )
					then Case when  (ShiftTemplate.ResCutoffTime >  @restaurant_real_time) then 	ShiftTemplate.ResCutoffTime
						else 2 end
  					else 
   						ShiftTemplate.ResCutoffTime
  					end)
   				and (@res_date + ReservationTemplate.SlotTime) >= @min_advance_res_time
  				and ReservationTemplate.SlotID not in
   					(select SlotID from TemplateReservation
   					inner join reservation on
   					TemplateReservation.ResID = reservation.ResID where
   					TemplateReservation.RID = r.RID
   					and TemplateReservation.ShiftDate = @res_date
     					and reservation.RStateID = 1 )
				)
, 0) 
  else r.CreateDate
  end) as F3
  
		,r.CreateDate as T1
		,r.CreateDate as T2
		,r.CreateDate as T3
		,@TimeZone_adjustment as RealTimeOffset
		,n.NbhoodName as NeighborhoodName
		,r.PriceQuartileID as Price_Quartile_ID
		,(case when r.Allotment = 1 then 0 else coalesce(DTi.IncentiveCount,0) end) as IncentiveCount
		,(case when r.Allotment = 1 then 0 else coalesce(DTi.exactAmount,0) end) as exactAmount
		,(case when r.Allotment = 1 then 0 else coalesce(DTi.AmountForAll,0)end) as AmountForAll
		,r.RName as P1
		,r.RName as P2
		,r.RName as P3
		,r.RankingPoints as I1
		,r.RankingPoints as I2
		,r.RankingPoints as I3
		,@lead_time as lead_time
		,(CASE  WHEN (dateadd(minute, @lead_time_value, @restaurant_real_time) - @ResDateTime) < 0 then 1 ELSE 0 END) as lead_time_ok
		,(case  when (@restaurant_real_time - coalesce(DTco.CutOff ,cast('11:59 PM' as datetime))) < 0 then 0 else 1 end) as aftercutoff
		,Right(cast(DTco.CutOff as nvarchar(20)), 7) as cutoff_time
		,@issamedayreso as samedayreso
		,coalesce(lower(DTco.Sname), '')as meal_period
		,r.TZID as TimesReturned
		,0 as NextAvailable
		,(case coalesce(rcm.Message, '') when '' then 0 else 1 end) as HasNoTimesMessage
		,coalesce(rcm.Message,(r.RName+' has no tables available for the partysize, date and time requested.')) as NoTimesMessage 
		,(case 	r.Allotment when 1 then 1 else case r.IsReachable when 1 then 1 else 0  end  end) as IsReachable 
		,coalesce(ft2.FoodType, '') 'FoodType'
		,@lead_time_value as lead_time_value
		, 1 as Searchable
		, ProductID as Product_ID
		, ProductID as SearchStatus
		,coalesce(bd.message,'') as BlockedDayMessage

FROM        RestaurantVW r
INNER JOIN  FoodTypes fts
ON          r.RID                 = fts.RID
AND         (LEN(@FoodTypes) = 0 OR CHARINDEX(',' + CAST(fts.sftid AS nvarchar(16)) + ',', ',' + @FoodTypes + ',') > 0)
inner join  FoodTypes fts2
on          r.RID = fts2.RID
and         fts2.IsPrimary = 1
inner join  FoodType ft2
on          fts2.FoodTypeID = ft2.FoodTypeID
and			ft2.LanguageID = r.LanguageID
INNER JOIN  NeighborhoodAVW n
ON          r.NeighborhoodID               = n.NeighborhoodID
and			r.LanguageID = n.Languageid
and         n.MetroAreaID                 = @GeoID
AND         (LEN(@MacroNeighborhoods) = 0 OR CHARINDEX(',' + CAST(n.MacroID AS nvarchar(16)) + ',', ',' + @MacroNeighborhoods + ',') > 0)    
INNER JOIN  TimeZone tz
ON          r.TZID                  = tz.TZID
INNER JOIN  ERBRestaurant er
ON          r.RID                 = er.RID
INNER JOIN  MinOnlineOption moo
ON          r.MinOnlineOptionID          = moo.MinOnlineOptionID
INNER JOIN  MaxOnlineOption mxo
ON          r.MaxLargePartyID            = mxo.MaxOnlineOptionID
INNER JOIN	MaxOnlineOption mxo2  -- used for AcceptLargeParty = 0
ON		r.MaxOnlineOptionID = mxo2.MaxOnlineOptionID
INNER JOIN  MaxAdvanceOption mao
ON          r.MaxAdvanceOptionID         = mao.MaxAdvanceOptionID
LEFT JOIN 	BlockedDayVW bd 
ON 		bd.rid=r.rid and bd.blockeddate=@res_date and bd.blockeddate >= getdate()
LEFT JOIN	RestaurantCustomMessage rcm
ON			r.RID = rcm.RID
and			r.LanguageID = rcm.LanguageID
and			rcm.MessageTypeId = @NoTimesMessage
left join
(select i.RID
		,count(i.IncentiveID) 'IncentiveCount'
		,bob2.exactAmount
		,bob.AmountForAll
		from IncentiveVW i
		left join
		(select i.RID
		,i.Amount 'exactAmount'
		from IncentiveVW i
		where i.IncentiveDay = @weekday
		and i.Active = 1 
		and i.LastMinutePopThresholdTime IS NULL
		and i.StartDate <= @res_date 
		and i.EndDate >= @res_date
		and i.StartTime <= @res_time
		and i.EndTime  > @res_time 
		) as bob2
		on i.RID = bob2.RID
		left join
		(select
		i.RID,
		i.Amount 'AmountForAll'
		from IncentiveVW i
		where  i.IncentiveDay = @weekday
		and i.Active = 1 
		and i.LastMinutePopThresholdTime IS NULL
		and i.StartDate <= @res_date
		and i.EndDate >= @res_date
		and i.StartTime <= @min_search_time  
		and i.EndTime  > @max_search_time) as bob
		on i.RID = bob.RID
		where i.IncentiveDay = @weekday
		and i.Active = 1 
		and i.LastMinutePopThresholdTime IS NULL
		and i.StartDate <= @res_date 
		and i.EndDate >= @res_date 
		and ((i.StartTime <= @res_time  and i.EndTime  > @res_time) 
		  or (i.StartTime >= @res_time  and i.StartTime <= @max_search_time) 
		  or (i.EndTime <= @res_time  and i.EndTime  > @min_search_time ))
		group by i.RID
		,bob2.exactAmount
		,bob.AmountForAll
) as DTi
on r.RID = DTi.RID

left join
(select st.RID
		,st.ResCutoffTime 'CutOff'
		,s.ShiftName 'SName'
		from ShiftTemplate st
		inner join ScheduleShifts ss
		on st.ShiftTemplateID = ss.ShiftTemplateID
		and st.RID = ss.RID
		inner join shift s
		on ss.ShiftID = s.ShiftID
		where ss.ScheduleID = coalesce((select ScheduleID from SpcSchAssign
   						where SpcSchAssign.RID = st.RID and
   						cast(convert(nvarchar, AssignmentDate, 110) as datetime) = @res_date),@weekday)
		and st.ShiftID = ss.ShiftID
		and st.Active = 1
		and st.CutoffActive = 1
		and st.OpenTime <= @res_time
		and st.CloseTime > @res_time
) as DTco
on r.RID = DTco.RID

WHERE      (r.RestStateID = 1)
AND       ((r.IsReachable = 1) or  (r.Allotment = 1 and r.RestStateID = 1))
AND (LEN(@PriceRange) = 0 OR CHARINDEX(',' + CAST(r.PriceQuartileID AS nvarchar(16)) + ',', ',' + @PriceRange + ',') > 0)
AND			r.Allotment <> 1 --** EV: 11/30/2009: Never allow allotment / console in legacy APIs
GO

GRANT EXECUTE ON [Restaurant_ListByFoodTypesPricesAndMacroNeighborhoods] TO ExecuteOnlyRole

GO

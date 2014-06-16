if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobIdentifyRestaurantWeekResID]') and objectproperty(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobIdentifyRestaurantWeekResID]
GO


CREATE PROCEDURE dbo.JobIdentifyRestaurantWeekResID (
@DateOffset int = 1  -- 1 means datemade for yesterday's reso activities
)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @RowToBeDeletedCount int


-- avoid locking issue - use temparary table
if object_id('tempdb..#temp_RWResIDRemoval') is not null
	drop table #temp_RWResIDRemoval
	
create table #temp_RWResIDRemoval (ResID int)

--**********************************************************
--** Identify Resos that have been changed after the fact
--** Compare Origianl State of record to current state of record to determine if rcord has changed
--** A reso is considered changed if:
--**	it has been moved to a different day
--**	it has been moved to a different restaurant
--**	it has been moved to a different shift
--**
--** Resos detected as changed will be revaluated to determine if they are still participating in rest week 
--** (based on rules as they exist at the time of the job run)
--**********************************************************
insert into	#temp_RWResIDRemoval(ResID)
select		rw.resid
from		ReservationRestaurantWeek rw
inner join	Reservation reso
on			rw.ResID = reso.ResID
inner join	ReservationLog resolog
on			rw.ResLogID = resolog.ResLogID

where		reso.ShiftDate > GETDATE() - (5 + @DateOffset) -- concentrate on recently past and future resos 
and 		(
			-- Determine if Day of reso changed
			reso.ShiftDate <>  convert(date, resolog.ShiftDT)  -- convert to midnight
			-- Determine if RID of reso changed
or			reso.RID <> resolog.RID
			-- Determine if Reso moved to a different shift (this is conservitive and allwows some flexibility in resos moving on the same day)
or			(case when reso.ResTime between '1899-12-30 00:00:00.000' and  '1899-12-30 15:59:59.993' then 'L' else 'D' End) <> rw.Shift
)

create clustered index CLX_temp_RWResIDRemoval on #temp_RWResIDRemoval(ResID)


--*******************************
--** Log each reslogid to be removed due to shiftdate or shifttime or rid changed
--*******************************
insert into ErrorLogVW (ErrTimeStamp, ErrSeverity, ErrorId, ErrStackTrace, ErrMsg)
select 		getdate(), 
			1, 
			rw.reslogid, 
			'RestWeek_ReslogIDToBeRemoved', 
			'ReslogID: ' + convert(varchar, ReslogID)
from		#temp_RWResIDRemoval rm
inner join	ReservationRestaurantWeek rw
on			rm.resid = rw.resid

--***************************************************
--** Mark resos for re-evaluation by simply deleting records identified in #temp_RWResIDRemoval
--***************************************************
delete		rw
from		ReservationRestaurantWeek rw
inner join	#temp_RWResIDRemoval rwr
on			rw.ResID = rwr.ResID

select @RowToBeDeletedCount = @@rowcount

--*****************************
--* Log Number of records affected
--*****************************
insert into ErrorLogVW (ErrTimeStamp, ErrSeverity, ErrorId, ErrStackTrace, ErrMsg)
select getdate(), 
		1, 
		@RowToBeDeletedCount, 
		'RestWeek_RowsToBeRemoved_Total', 
		'Records affected: ' + convert(varchar, @RowToBeDeletedCount) 

-- end logging


select      pp.PromoID
			,pr.RID
			,pr.Dinner
			,pr.Lunch
			,pp.EventStartDate
			,pp.EventEndDate
into        #ActiveRestWeekPromos
from        PromoPages pp
inner join  PromoRests pr
on          pp.PromoID = pr.PromoID
inner join	PromoPagesToPromoGroups pptpg
on			pp.PromoID = pptpg.PromoID
where		pptpg.PromoGroupTypeID = 1 and pptpg.active = 1  -- this flag is identified in the CHARM checkbox
and         pp.active = 1
and         pp.EventEndDate > GETDATE() - (30 + @DateOffset) -- Only look at recent events


-- Identify Resos that qualify for Rest Week
insert into ReservationRestaurantWeek(ResID, PromoID, Shift, CreateDT, ResLogID)
select 		r.ResID
			,min(arw.promoid) promoID  -- Pick the first match if there are multiple
			,case when arw.Lunch =1 and r.ResTime between '1899-12-30 00:00:00.000' and  '1899-12-30 15:59:59.993' then 'L' else 'D' End 'Shift'
	   	    ,getdate() CreateDate -- for report use
			,(select MAX(resolog.ResLogID) from ReservationLog resolog where resolog.resid = r.resid)   	    
from 		Reservation r
inner join  #ActiveRestWeekPromos arw
on          r.RID = arw.rid
and         r.ShiftDate between arw.EventStartDate and arw.EventEndDate
left join   PromoPageExclusions ppe
on          ppe.PromoID = arw.promoID
and         r.shiftdate = ppe.ExclusionDate
left join	ReservationRestaurantWeek rw
on			rw.ResID = r.ResID
where       r.ShiftDate > GETDATE() - (5 + @DateOffset) -- Optimization never look too far back in partitions
and			rw.ResID is null -- Make sure we haven't already detected this Reso
-- Enforce Exlusion Dates
and         ppe.ExclusionDate is null
-- Determine if Restaurant is currently active
and         ((arw.Lunch = 1 and r.ResTime between '1899-12-30 00:00:00.000' and '1899-12-30 15:59:59.993')
            or                
            (arw.dinner = 1 and r.ResTime between '1899-12-30 16:00:00.000' and '1899-12-30 23:59:59.993') 
            )
group by 	r.ResID
			,Case when arw.Lunch =1 and r.ResTime between '1899-12-30 00:00:00.000' and  '1899-12-30 15:59:59.993' then 'L' else 'D' End



-- cleanup temporary tables
if object_id('tempdb..#temp_RWResIDRemoval') is not null
	drop table #temp_RWResIDRemoval

GO

GRANT EXECUTE ON [JobIdentifyRestaurantWeekResID] TO ExecuteOnlyRole

GO

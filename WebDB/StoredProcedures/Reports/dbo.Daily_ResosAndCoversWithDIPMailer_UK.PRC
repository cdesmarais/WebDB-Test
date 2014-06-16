if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_ResosAndCoversWithDIPMailer_UK]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_ResosAndCoversWithDIPMailer_UK]
go


CREATE  PROCEDURE dbo.Daily_ResosAndCoversWithDIPMailer_UK 
(
@strDateOffset int
)

AS


declare @rptDt datetime  
,@subj nvarchar(100)  
,@bdy nvarchar(4000)  
,@TDailyStats nvarchar(50)  
,@TMonthlyStats nvarchar(100)  
,@TPreviousMonthStats nvarchar(80)  
,@dOTCovers nvarchar(50)  
,@dDIPCovers nvarchar(50)  
,@dRestRefCovers nvarchar(50)  
,@dTotalCovers nvarchar(50)  
,@mOTCovers nvarchar(50)  
,@mDIPCovers nvarchar(50)  
,@mRestRefCovers nvarchar(50)  
,@mTotalCovers nvarchar(50)  
,@pTotalCovers nvarchar(50)  
,@pwOTCovers nvarchar(50)  
,@pwDIPCovers nvarchar(50)  
,@pwRestRefCovers nvarchar(50)  
,@pwTotalCovers nvarchar(50) 
,@pmOTCovers nvarchar(50)  
,@pmDIPCovers nvarchar(50)  
,@pmRestRefCovers nvarchar(50)  
,@pmTotalCovers nvarchar(50)
,@TPreviousMonthToDate nvarchar(100)
,@TPreviousWeek nvarchar(100)


set transaction isolation level read uncommitted
SET NOCOUNT ON

declare @DayDate datetime
declare @MonthDate datetime
declare @PrevMonthDate datetime
declare @LastWeekDayDate datetime  
declare @PrevMonthDayDate datetime  

set @rptDt = (select (getdate()-(@strDateOffset+2)))
set @DayDate = dateadd(d, DATEDIFF(d, 0, @rptDt), 0)
set @MonthDate = dateadd(m, DATEDIFF(m, 0, @rptDt), 0)
set @PrevMonthDate = dateadd(m, -1, @MonthDate)
set @LastWeekDayDate = dateadd(d, -7, @DayDate)
set @PrevMonthDayDate = dateadd(m, -1, @DayDate)  

set @subj = 'London/UK Resos/Covers Month to Date - '+ convert(nvarchar(10),@rptDt, 101)
set @TDailyStats = 'Daily Reservation Statistics: ( '+ convert(nvarchar(10),@rptDt, 101)+' )'
set @TMonthlyStats = 'Monthly Reservation Statistics: ( ' + convert(nvarchar(10),@MonthDate , 101)+' ) to ( '+ convert(nvarchar(10),@DayDate , 101)+' )'
set @TPreviousMonthStats ='Previous Month Reservation Statistics: ( ' + DATENAME(MM, @PrevMonthDate) + ' ' + CAST(YEAR(@PrevMonthDate) AS VARCHAR(4)) +' )'  
set @TPreviousMonthToDate ='Previous Month Reservation To Date Statistics: ( '+ convert(nvarchar(10),@PrevMonthDate , 101)+' ) to ( '+ convert(nvarchar(10),@PrevMonthDayDate , 101)+' )'
set @TPreviousWeek = 'Daily Reservation Statistics Last Week: ( '+ convert(nvarchar(10),@LastWeekDayDate, 101)+ ' )'  

--Get the Daily Reservation Statistics
select   
 @dOTCovers='OT Covers: '+ COALESCE(cast(sum(case when BillingType = 'OTReso' and res.ShiftDate = @DayDate then res.BillableSize else 0 end)  as varchar(12)),'0'),  
 @dDIPCovers='POP Covers: '+ COALESCE(cast(sum(case when BillingType = 'DIPReso' and res.ShiftDate = @DayDate then res.BillableSize else 0 end)  as varchar(12)),'0'),  
 @dRestRefCovers='RestRef Covers: '+ COALESCE(cast(sum(case when BillingType = 'RestRefReso' and res.ShiftDate = @DayDate then res.BillableSize else 0 end)  as varchar(12)),'0'),  
 @dTotalCovers = 'Total Covers: ' + COALESCE(cast(sum(case when res.ShiftDate = @DayDate then res.BillableSize else 0 end)  as varchar(12)),'0'),  
   
 @mOTCovers='OT Covers: '+ COALESCE(cast(sum(case when BillingType = 'OTReso' and res.ShiftDate between @MonthDate and @DayDate then res.BillableSize else 0 end)  as varchar(12)),'0'),  
 @mDIPCovers='POP Covers: '+ COALESCE(cast(sum(case when BillingType = 'DIPReso' and res.ShiftDate between @MonthDate and @DayDate then res.BillableSize else 0 end)  as varchar(12)),'0'),  
 @mRestRefCovers='RestRef Covers: '+ COALESCE(cast(sum(case when BillingType = 'RestRefReso' and res.ShiftDate between @MonthDate and @DayDate then res.BillableSize else 0 end)  as varchar(12)),'0'),  
 @mTotalCovers = 'Total Covers: ' + COALESCE(cast(sum(case when res.ShiftDate between @MonthDate and @DayDate then res.BillableSize else 0 end)  as varchar(12)),'0'),  
  
 @pwOTCovers='Previous ' + DATENAME(dw,@LastWeekDayDate) + ' OT Covers: '+ COALESCE(cast(sum(case when BillingType = 'OTReso' and res.ShiftDate = @LastWeekDayDate then res.BillableSize else 0 end)  as varchar(12)),'0'),  
 @pwDIPCovers='Previous ' + DATENAME(dw,@LastWeekDayDate) + ' POP Covers: '+ COALESCE(cast(sum(case when BillingType = 'DIPReso' and res.ShiftDate = @LastWeekDayDate then res.BillableSize else 0 end)  as varchar(12)),'0'),  
 @pwRestRefCovers='Previous ' + DATENAME(dw,@LastWeekDayDate) + ' RestRef Covers: '+ COALESCE(cast(sum(case when BillingType = 'RestRefReso' and res.ShiftDate = @LastWeekDayDate then res.BillableSize else 0 end)  as varchar(12)),'0'),  
 @pwTotalCovers = 'Previous ' + DATENAME(dw,@LastWeekDayDate) + ' Total Covers: ' + COALESCE(cast(sum(case when res.ShiftDate = @LastWeekDayDate then res.BillableSize else 0 end)  as varchar(12)),'0'),  

 @pmOTCovers='Previous Month to Date OT Covers: '+ COALESCE(cast(sum(case when BillingType = 'OTReso' and res.ShiftDate between @PrevMonthDate and @PrevMonthDayDate then res.BillableSize else 0 end)  as varchar(12)),'0'),  
 @pmDIPCovers='Previous Month to Date POP Covers: '+ COALESCE(cast(sum(case when BillingType = 'DIPReso' and res.ShiftDate between @PrevMonthDate and @PrevMonthDayDate then res.BillableSize else 0 end)  as varchar(12)),'0'),  
 @pmRestRefCovers='Previous Month to Date RestRef Covers: '+ COALESCE(cast(sum(case when BillingType = 'RestRefReso' and res.ShiftDate between @PrevMonthDate and @PrevMonthDayDate then res.BillableSize else 0 end)  as varchar(12)),'0'),  
 @pmTotalCovers = 'Previous Month to Date Total Covers: ' + COALESCE(cast(sum(case when res.ShiftDate between @PrevMonthDate and @PrevMonthDayDate then res.BillableSize else 0 end)  as varchar(12)),'0'),

 @pTotalCovers = 'Total Covers for Previous Month: ' + COALESCE(cast(sum(case when res.ShiftDate >= @PrevMonthDate and res.ShiftDate < @MonthDate then res.BillableSize else 0 end)  as varchar(12)),'0')  
 	
from		ReservationVW res (nolock)
inner join	neighborhood n
on			res.NeighborhoodID = n.NeighborhoodID 
inner join	MetroArea ma
on			n.MetroAreaID = ma.MetroAreaID
and			ma.CountryID = 'UK'
where		res.ShiftDate between  @PrevMonthDate and @DayDate 
and			res.RStateID in (1,2,5,6,7)
and			n.MetroAreaID <> 1
and			SuppressFromBilling = 0




set @bdy = N'London/UK Resos/Covers Month to date Information:'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+
@TDailyStats+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+
'  '+@dOTCovers+CHAR(13)+CHAR(10)+
'  '+@dDIPCovers+CHAR(13)+CHAR(10)+
'  '+@dRestRefCovers+CHAR(13)+CHAR(10)+
'  '+@dTotalCovers+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+
@TPreviousWeek+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+
'  '+@pwOTCovers+CHAR(13)+CHAR(10)+
'  '+@pwDIPCovers+CHAR(13)+CHAR(10)+
'  '+@pwRestRefCovers+CHAR(13)+CHAR(10)+
'  '+@pwTotalCovers+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+
@TMonthlyStats+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+
'  '+@mOTCovers+CHAR(13)+CHAR(10)+
'  '+@mDIPCovers+CHAR(13)+CHAR(10)+
'  '+@mRestRefCovers+CHAR(13)+CHAR(10)+
'  '+@mTotalCovers+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+
@TPreviousMonthToDate+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+
'  '+@pmOTCovers+CHAR(13)+CHAR(10)+
'  '+@pmDIPCovers+CHAR(13)+CHAR(10)+
'  '+@pmRestRefCovers+CHAR(13)+CHAR(10)+
'  '+@pmTotalCovers+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+
@TPreviousMonthStats+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+
'  '+@pTotalCovers

exec master..sp_send_cdosysmail 
 @From = 'stats@opentable.com'
,@To = 'stats@opentable.com;execstaff@opentable.com,DailyStats_UK@opentable.com'
,@Subject = @subj
,@Body = @bdy

GO

GRANT EXECUTE ON [Daily_ResosAndCoversWithDIPMailer_UK] TO ExecuteOnlyRole

GO

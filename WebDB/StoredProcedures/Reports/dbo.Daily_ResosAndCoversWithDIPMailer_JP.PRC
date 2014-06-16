if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_ResosAndCoversWithDIPMailer_JP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_ResosAndCoversWithDIPMailer_JP]
go


CREATE  PROCEDURE dbo.Daily_ResosAndCoversWithDIPMailer_JP 
(
@strDateOffset int
)

AS

declare @rptDt datetime
,@subj nvarchar(100)
,@bdy nvarchar(4000)
,@TDailyStats nvarchar(50)
,@TMonthlyStats nvarchar(50)
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


set @rptDt = (select (getdate()-(@strDateOffset+2)))
set @subj = 'Resos/Covers Month to Date - '+ convert(nvarchar(10),@rptDt, 101)
set @TDailyStats = 'Daily Reservation Statistics: ( '+ convert(nvarchar(10),@rptDt, 101)+' )'
set @TMonthlyStats = 'Monthly Reservation Statistics: ( ' + DATENAME(MM, @rptDt) + ' ' + CAST(YEAR(@rptDt) AS VARCHAR(4)) +' )'
set @TPreviousMonthStats ='Previous Month Reservation Statistics: ( ' + DATENAME(MM, dateadd(m,-1,@rptDt)) + ' ' + CAST(YEAR(dateadd(m, -1, @rptDt)) AS VARCHAR(4)) +' )'


set transaction isolation level read uncommitted
SET NOCOUNT ON

declare @DayDate datetime
declare @MonthDate datetime
declare @PrevMonthDate datetime

set @DayDate = dateadd(d, DATEDIFF(d, 0, @rptDt), 0)
set @MonthDate = dateadd(m, DATEDIFF(m, 0, @rptDt), 0)
set @PrevMonthDate = dateadd(m, -1, @MonthDate)

--Get the Daily Reservation Statistics
select 
	@dOTCovers='OT Covers: '+ COALESCE(cast(sum(case when BillingType = 'OTReso' and res.ShiftDate = @DayDate then res.BillableSize else 0 end)  as char(7)),'0'),
	@dDIPCovers='POP Covers: '+ COALESCE(cast(sum(case when BillingType = 'DIPReso' and res.ShiftDate = @DayDate then res.BillableSize else 0 end)  as char(7)),'0'),
	@dRestRefCovers='RestRef Covers: '+ COALESCE(cast(sum(case when BillingType = 'RestRefReso' and res.ShiftDate = @DayDate then res.BillableSize else 0 end)  as char(7)),'0'),
	@dTotalCovers = 'Total Covers: ' + COALESCE(cast(sum(case when res.ShiftDate = @DayDate then res.BillableSize else 0 end)  as char(7)),'0'),
	
	@mOTCovers='OT Covers: '+ COALESCE(cast(sum(case when BillingType = 'OTReso' and res.ShiftDate between @MonthDate and @DayDate then res.BillableSize else 0 end)  as char(7)),'0'),
	@mDIPCovers='POP Covers: '+ COALESCE(cast(sum(case when BillingType = 'DIPReso' and res.ShiftDate between @MonthDate and @DayDate then res.BillableSize else 0 end)  as char(7)),'0'),
	@mRestRefCovers='RestRef Covers: '+ COALESCE(cast(sum(case when BillingType = 'RestRefReso' and res.ShiftDate between @MonthDate and @DayDate then res.BillableSize else 0 end)  as char(7)),'0'),
	@mTotalCovers = 'Total Covers: ' + COALESCE(cast(sum(case when res.ShiftDate between @MonthDate and @DayDate then res.BillableSize else 0 end)  as char(7)),'0'),

	@pTotalCovers = 'Total Covers for Previous Month: ' + COALESCE(cast(sum(case when res.ShiftDate >= @PrevMonthDate and res.ShiftDate < @MonthDate then res.BillableSize else 0 end)  as char(7)),'0')
	
from		ReservationVW res (nolock)
inner join	neighborhood n
on			res.NeighborhoodID = n.NeighborhoodID 
where		res.ShiftDate between  @PrevMonthDate and @DayDate 
and			res.RStateID in (1,2,5,6,7)
and			n.MetroAreaID <> 1


declare @dbName nvarchar(100)
declare @website nvarchar(100)
declare @ToEmail nvarchar(100)
select @dbName = db_name(db_id())

--******************
--** Conditionally Correct Email subject line title
--******************
if (@dbName = 'Webdb')
	Begin
	set @website = 'North America Website: '
	set @ToEmail = 'DailyStats_US@opentable.com;stats@opentable.com'
	END
else if (@dbName = 'Webdb_Asia')
	Begin
	set @website = 'Asia Website: ' 
	set @ToEmail = 'DailyStats_Asia@opentable.com;stats@opentable.com'
	End

set @subj = @website + @subj
set @bdy = @website + N'Resos/Covers Month to date Information:

'+ @TDailyStats +'

'+@dOTCovers+'
'+@dDIPCovers+'
'+@dRestRefCovers +'
'+@dTotalCovers+'

'+ @TMonthlyStats +'

'+@mOTCovers +'
'+@mDIPCovers+'
'+@mRestRefCovers +'
'+@mTotalCovers+'

'+ @TPreviousMonthStats +'

'+@pTotalCovers

exec master..sp_send_cdosysmail 
 @From = 'stats@opentable.com'
,@To = @ToEmail 
,@Subject = @subj
,@Body = @bdy

GO

GRANT EXECUTE ON [Daily_ResosAndCoversWithDIPMailer_JP] TO ExecuteOnlyRole

GO

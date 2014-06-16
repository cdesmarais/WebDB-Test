if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Get_MetroDetailsRegs]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Get_MetroDetailsRegs]
GO

CREATE PROCEDURE dbo.Report_Get_MetroDetailsRegs
(
  @metroName int,
  @reportDate datetime = Null
)
AS
SET NOCOUNT ON
set transaction isolation level read uncommitted

Declare @lastfromdate datetime
,@qtrfromdate datetime
,@qtrEnddate datetime
,@qtrfrommonth int
, @fromdate datetime
,@ytdfromdate datetime
,@fromDateEnd datetime


set @fromDate  = coalesce(@reportDate,getdate())
set @fromDate  = Cast(convert(nvarchar,dateadd(day,-(day(@fromDate)-1), @fromDate),101) as datetime)

set @fromDateEnd  = dateadd(m,1,@fromDate)

Select @lastfromdate = dateadd(m,-1,@fromdate) --get prior month's date from range
Select @qtrfrommonth = (Month(@fromdate) - QtrStart) From QuarterRef Where MonthNum = Month(@fromdate)
Select @qtrfromdate = dateadd(m,-@qtrfrommonth,@fromDate)
Select @qtrEnddate = dateadd(m,3, @qtrfromdate)

Select @ytdfromdate = dateadd(month,-(month(@fromdate)-1),@fromdate)

-- Get the earliest relevent date
declare @minDate datetime
select @minDate = min(dt)
from (select @lastfromdate dt 
union select @qtrfromdate dt 
union select @ytdfromdate dt) t

Select MetroAreaName as Name
,datediff(day,@fromDate, @fromDateEnd) as cdays
,datediff(day,@lastfromdate, @fromDate) as ldays
,datediff(day,@qtrfromdate, @fromDateEnd) as qtrdays
,datediff(day,@ytdfromdate, @fromDateEnd) as ytddays
,Sum(
	case when ReportDate = @fromDate then regs 
	else 0 end	
) as regs
,Sum(
	case when ReportDate = @lastfromdate then regs 
	else 0 end	
) as last_regs
,Sum(
	case when ReportDate >= @qtrfromdate and ReportDate < @qtrEndDate then regs 
	else 0 end	
) as qtr_regs
,Sum(
	case when ReportDate >= @ytdfromdate then regs 
	else 0 end	
) as ytd_regs
,Sum(
	case when ReportDate = @fromDate then Refs 
	else 0 end	
) as Refs
,Sum(
	case when ReportDate = @lastfromdate then Refs 
	else 0 end	
) as Last_Refs
,Sum(
	case when ReportDate >= @qtrfromdate and ReportDate < @qtrEndDate then Refs 
	else 0 end	
) as Qtr_Refs
,Sum(
	case when ReportDate >= @ytdfromdate then Refs 
	else 0 end	
) as Ytd_Refs
from MetroAreaVW ma
left join RegistrationRPTSummary tcrd
	on ma.MetroAreaID = tcrd.MetroAreaID
	and ReportDate between @minDate and @fromDate
where ma.MetroAreaID= @metroName
group by MetroAreaName

GO


GRANT EXECUTE ON [Report_Get_MetroDetailsRegs] TO ExecuteOnlyRole

GO

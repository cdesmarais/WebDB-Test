if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Top5Restaurants_Billable]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Top5Restaurants_Billable]
GO

CREATE Procedure dbo.Report_Top5Restaurants_Billable
(
  @reportDate datetime = Null
)
AS
set transaction isolation level read uncommitted
SET NOCOUNT ON

Declare @lastfromdate datetime
,@qtrfromdate datetime
,@qtrEnddate datetime
,@qtrfrommonth int
, @fromdate datetime
,@ytdfromdate datetime


set @fromDate  = coalesce(@reportDate,getdate())
set @fromDate  = Cast(convert(nvarchar,dateadd(day,-(day(@fromDate)-1), @fromDate),101) as datetime)

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



Select Top 5 ReportRestaurant.MetroAreaName
	,Sum(
		case when ReportDate = @fromDate then Resos 
		else 0 end
	) as Resos
	,sum(
		case when ReportDate = @lastfromdate then Resos 
		else 0 end
	) as last_resos
	,sum(
		case when ReportDate >= @qtrfromdate and ReportDate < @qtrEndDate then Resos 
		else 0 end	
	) as qtr_resos
	,sum(
		case when ReportDate >= @ytdfromdate then Resos 
		else 0 end
	) as ytd_resos
from ReportRestaurant
left join ReservationRPTSummary 
on ReportRestaurant.RID = ReservationRPTSummary.RID
	and ReportDate between @minDate and @fromDate
group by MetroAreaName
order by resos desc

GO


GRANT EXECUTE ON [Report_Top5Restaurants_Billable] TO ExecuteOnlyRole

GO

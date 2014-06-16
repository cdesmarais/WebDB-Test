if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Get_MetroRestaurant]') and OBJECTPROPERTY(id,N'IsProcedure') = 1)
drop procedure [dbo].[Report_Get_MetroRestaurant]
GO

CREATE PROCEDURE dbo.Report_Get_MetroRestaurant
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


Select RName 'Name'
	, ReportRestaurant.rid as restaurant_ID
	,Sum(
		case when ReportDate = @fromDate then Resos 
		else 0 end
	) as Resos
	,sum(
		case when ReportDate = @fromDate then Covers 
		else 0 end
	) as covers
	,sum(
		case when ReportDate = @fromDate then dining 
		else 0 end
	) as dining
	,sum(
		case when ReportDate = @lastfromdate then Resos 
		else 0 end
	) as last_resos
	,sum(
		case when ReportDate = @lastfromdate then Covers 
		else 0 end
	) as last_covers
	,sum(
		case when ReportDate = @lastfromdate then dining 
		else 0 end
	) as last_dining
	,sum(
		case when ReportDate >= @qtrfromdate and ReportDate < @qtrEndDate then Resos 
		else 0 end	
	) as qtr_resos
	,sum(
		case when ReportDate >= @qtrfromdate and ReportDate < @qtrEndDate then Covers 
		else 0 end	
	) as qtr_covers
	,sum(
		case when ReportDate >= @qtrfromdate and ReportDate < @qtrEndDate then dining 
		else 0 end	
	) as qtr_dining
	,sum(
		case when ReportDate >= @ytdfromdate then Resos 
		else 0 end
	) as ytd_resos
	,sum(
		case when ReportDate >= @ytdfromdate then Covers 
		else 0 end
	) as ytd_covers
	,sum(
		case when ReportDate >= @ytdfromdate then dining 
		else 0 end
	) as ytd_dining
	,Sum(
		case when ReportDate = @fromDate then Business 
		else 0 end
	) as Business
	,Sum(
		case when ReportDate = @fromDate then Pleasure 
		else 0 end
	) as Pleasure
	,Sum(
		case when ReportDate = @fromDate then BpNc 
		else 0 end
	) as Bp_Nc
	,Sum(
		case when ReportDate = @fromDate then tfirst 
		else 0 end
	) as tfirst
	,Sum(
		case when ReportDate = @fromDate then tsecond 
		else 0 end
	) as tsecond	
	,Sum(
		case when ReportDate = @fromDate then TNc 
		else 0 end
	) as T_Nc					
	
	,sum(
		case when ReportDate = @lastfromdate then Business 
		else 0 end
	) as Last_Business
	,sum(
		case when ReportDate = @lastfromdate then Pleasure 
		else 0 end
	) as Last_Pleasure
	,sum(
		case when ReportDate = @lastfromdate then BpNc 
		else 0 end
	) as Last_Bp_Nc
	,sum(
		case when ReportDate = @lastfromdate then tfirst 
		else 0 end
	) as Last_tfirst
	,sum(
		case when ReportDate = @lastfromdate then tsecond 
		else 0 end
	) as Last_tsecond
	,sum(
		case when ReportDate = @lastfromdate then TNc 
		else 0 end
	) as Last_T_Nc

	,sum(
		case when ReportDate >= @qtrfromdate and ReportDate < @qtrEndDate then Business 
		else 0 end	
	) as Qtr_Business
	,sum(
		case when ReportDate >= @qtrfromdate and ReportDate < @qtrEndDate then Pleasure 
		else 0 end	
	) as Qtr_Pleasure
	,sum(
		case when ReportDate >= @qtrfromdate and ReportDate < @qtrEndDate then BpNc 
		else 0 end	
	) as Qtr_Bp_Nc
	,sum(
		case when ReportDate >= @qtrfromdate and ReportDate < @qtrEndDate then tfirst 
		else 0 end	
	) as Qtr_tfirst
	,sum(
		case when ReportDate >= @qtrfromdate and ReportDate < @qtrEndDate then tsecond 
		else 0 end	
	) as Qtr_tsecond
	,sum(
		case when ReportDate >= @qtrfromdate and ReportDate < @qtrEndDate then TNc 
		else 0 end	
	) as Qtr_T_Nc			
	
	,sum(
		case when ReportDate >= @ytdfromdate then Business 
		else 0 end
	) as Ytd_Business
	,sum(
		case when ReportDate >= @ytdfromdate then Pleasure 
		else 0 end
	) as Ytd_Pleasure
	,sum(
		case when ReportDate >= @ytdfromdate then BpNc 
		else 0 end
	) as Ytd_Bp_Nc			
	,sum(
		case when ReportDate >= @ytdfromdate then tfirst 
		else 0 end
	) as Ytd_tfirst
	,sum(
		case when ReportDate >= @ytdfromdate then Tsecond 
		else 0 end
	) as Ytd_Tsecond
	,sum(
		case when ReportDate >= @ytdfromdate then TNc 
		else 0 end
	) as YtD_t_Nc			
--	
	,Sum(
		case when ReportDate = @fromDate then dis 
		else 0 end
	) as dis					
	,sum(
		case when ReportDate = @lastfromdate then dis 
		else 0 end
	) as Last_dis
	,sum(
		case when ReportDate >= @qtrfromdate and ReportDate < @qtrEndDate then dis 
		else 0 end	
	) as Qtr_dis			
	,sum(
		case when ReportDate >= @ytdfromdate then dis 
		else 0 end
	) as Ytd_dis
--
	,Sum(
		case when ReportDate = @fromDate then disr 
		else 0 end
	) as dis_r
	,sum(
		case when ReportDate = @lastfromdate then disr 
		else 0 end
	) as last_dis_r
	,sum(
		case when ReportDate >= @qtrfromdate and ReportDate < @qtrEndDate then disr 
		else 0 end	
	) as qtr_dis_r			
	,sum(
		case when ReportDate >= @ytdfromdate then disr 
		else 0 end
	) as ytd_dis_r
--
	,Sum(
		case when ReportDate = @fromDate then nshow 
		else 0 end
	) as nshow
	,sum(
		case when ReportDate = @lastfromdate then nshow 
		else 0 end
	) as last_nshow
	,sum(
		case when ReportDate >= @qtrfromdate and ReportDate < @qtrEndDate then nshow 
		else 0 end	
	) as qtr_nshow			
	,sum(
		case when ReportDate >= @ytdfromdate then nshow 
		else 0 end
	) as ytd_nshow
	,RSName
from ReportRestaurant
left join ReservationRPTSummary 
on ReportRestaurant.RID = ReservationRPTSummary.RID
	and ReportDate between @minDate and @fromDate
where ReportRestaurant.MetroAreaID= @metroName
group By RName, RSName
,ReportRestaurant.RID
order by RSName, RName

GO


GRANT EXECUTE ON [Report_Get_MetroRestaurant] TO ExecuteOnlyRole

GO

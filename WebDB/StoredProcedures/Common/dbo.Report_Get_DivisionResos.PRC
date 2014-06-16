if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Get_DivisionResos]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Get_DivisionResos]
GO

CREATE Procedure dbo.Report_Get_DivisionResos
(
	@area nvarchar(50),
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


Select		ma.MetroAreaName as Name
			,sum(coalesce(resos,0)) as resos
			,sum(coalesce(covers,0)) as covers
			,sum(coalesce(dining,0)) as dining
			,sum(coalesce(Last_Resos,0)) as last_resos
			,sum(coalesce(Last_Covers,0)) as last_covers
			,sum(coalesce(last_dining,0)) as last_dining
			,sum(coalesce(qtr_resos,0)) as qtr_resos
			,sum(coalesce(qtr_covers,0)) as qtr_covers
			,sum(coalesce(qtr_dining,0)) as qtr_dining
			,sum(coalesce(ytd_resos,0)) as ytd_resos
			,sum(coalesce(ytd_covers,0)) as ytd_covers
			,sum(coalesce(ytd_dining,0)) as ytd_dining
			,sum(coalesce(regs,0)) as regs
			,sum(coalesce(last_regs,0)) as last_regs
			,sum(coalesce(qtr_regs,0)) as qtr_regs
			,sum(coalesce(ytd_regs,0)) as ytd_regs
			,IsNull(sum(rest),0) rest
			,IsNull(sum(last_rest),0) last_rest
			,IsNull(sum(qtr_rest),0) qtr_rest
			,IsNull(sum(ytd_rest),0) ytd_rest									
			,(case when IsNull(sum(rest),0) > 0 then IsNull(sum(resos),0) / IsNull(sum(rest),0) 
				else 0 end) as resosPerRest
			,(case when IsNull(sum(last_rest),0) > 0 then IsNull(sum(last_resos),0) / IsNull(sum(last_rest),0) 
				else 0 end) as last_resosPerRest
			,(case when IsNull(sum(qtr_rest),0) > 0 then IsNull(sum(qtr_resos),0) / IsNull(sum(qtr_rest),0) 
				else 0 end) as qtr_resosPerRest
			,(case when IsNull(sum(ytd_rest),0) > 0 then IsNull(sum(ytd_resos),0) / IsNull(sum(ytd_rest),0) 
				else 0 end) as ytd_resosPerRest
			,(case when IsNull(sum(rest),0) > 0 then IsNull(sum(covers),0) / IsNull(sum(rest),0) 
				else 0 end) as coversPerRest
			,(case when IsNull(sum(last_rest),0) > 0 then IsNull(sum(last_covers),0) / IsNull(sum(last_rest),0) 
				else 0 end) as last_coversPerRest
			,(case when IsNull(sum(qtr_rest),0) > 0 then IsNull(sum(qtr_covers),0) / IsNull(sum(qtr_rest),0) 
				else 0 end) as qtr_coversPerRest
			,(case when IsNull(sum(ytd_rest),0) > 0 then IsNull(sum(ytd_covers),0) / IsNull(sum(ytd_rest),0) 
				else 0 end) as ytd_coversPerRest
from MetroAreaVW ma
inner join(
Select ma.MetroAreaID,
	sum(
		case when ReportDate = @fromDate then Resos 
		else 0 end
	) as resos
	,sum(
		case when ReportDate = @fromDate then Covers 
		else 0 end
	) as covers
	,sum(
		case when ReportDate = @fromDate then dining 
		else 0 end
	) as dining
	,count(distinct 
		case when ReportDate = @fromDate then ResRPT.RID
		else null end
	) as rest
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
	,count(distinct 
		case when ReportDate = @lastfromdate then ResRPT.RID
		else null end
	) as last_rest
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
	,count(distinct 
		case when ReportDate >= @qtrfromdate and ReportDate < @qtrEndDate then ResRPT.RID
		else null end
	) as qtr_rest	
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
	,count(distinct 
		case when ReportDate >= @ytdfromdate then ResRPT.RID
		else null end
	) as ytd_rest	
			from MetroArea ma
	left join ReportRestaurant 
	on ma.MetroAreaID = ReportRestaurant.MetroAreaID
	left join ReservationRPTSummary ResRPT
	on ReportRestaurant.RID = ResRPT.RID
		and ReportDate between @minDate and @fromDate
	group by ma.MetroAreaID) as CursorTable 
on ma.MetroAreaID = CursorTable.MetroAreaID
inner join (
	Select ma.MetroAreaID
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
	from MetroArea ma
	left join RegistrationRPTSummary 
	on ma.MetroAreaID = RegistrationRPTSummary.MetroAreaID
		and ReportDate between @minDate and @fromDate
	group by ma.MetroAreaID) as CursorTable1 
on ma.MetroAreaID = CursorTable1.MetroAreaID
inner join territories t
on ma.MetroAreaID = t.MetroAreaID
and t.division = @area
group by ma.MetroAreaName
order by ma.MetroAreaName


GO


GRANT EXECUTE ON [Report_Get_DivisionResos] TO ExecuteOnlyRole

GO

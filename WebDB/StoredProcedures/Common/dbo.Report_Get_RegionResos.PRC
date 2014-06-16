if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Get_RegionResos]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Get_RegionResos]
GO

CREATE PROCEDURE dbo.Report_Get_RegionResos
(
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



Select territories.MetroAreaName as Name
			,coalesce(sum(coalesce(resos,0)),0) as resos
			,coalesce(sum(coalesce(covers,0)),0) as covers
			,coalesce(sum(coalesce(dining,0)),0) as dining
			,coalesce(sum(coalesce(Last_resos,0)),0) as last_resos
			,coalesce(sum(coalesce(Last_covers,0)),0) as last_covers
			,coalesce(sum(coalesce(Last_dining,0)),0) as last_dining
			,coalesce(sum(coalesce(Qtr_resos,0)),0) as qtr_resos
			,coalesce(sum(coalesce(Qtr_covers,0)),0) as qtr_covers
			,coalesce(sum(coalesce(Qtr_dining,0)),0) as qtr_dining
			,coalesce(sum(coalesce(Ytd_resos,0)),0) as ytd_resos
			,coalesce(sum(coalesce(Ytd_covers,0)),0) as ytd_covers
			,coalesce(sum(coalesce(Ytd_dining,0)),0) as ytd_dining
			,coalesce(sum(coalesce(regs,0)),0) as regs
			,coalesce(sum(coalesce(Last_regs,0)),0) as last_regs
			,coalesce(sum(coalesce(Qtr_regs,0)),0) as qtr_regs
			,coalesce(sum(coalesce(Ytd_regs,0)),0) as ytd_regs
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
from	MetroAreaVW territories
inner join	(Select		 territories.MetroAreaID
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
			from MetroArea territories
			left join ReportRestaurant 
			on territories.MetroAreaID = ReportRestaurant.MetroAreaID
			left join ReservationRPTSummary ResRPT
			on ReportRestaurant.RID = ResRPT.RID
				and ReportDate between @minDate and @fromDate
			group by territories.MetroAreaID) as CursorTable 
on territories.MetroAreaID = CursorTable.MetroAreaID

inner join	(Select		territories.MetroAreaID
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
			 from MetroArea territories
			 left join RegistrationRPTSummary 
			 on territories.MetroAreaID = RegistrationRPTSummary.MetroAreaID
				and ReportDate between @minDate and @fromDate
			 group by territories.MetroAreaID) 
as CursorTable1 on territories.MetroAreaID = CursorTable1.MetroAreaID
where territories.Active = 1
group by territories.MetroAreaName
order by territories.MetroAreaName

GO


GRANT EXECUTE ON [Report_Get_RegionResos] TO ExecuteOnlyRole

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Get_MetroDetailsResos]') and OBJECTPROPERTY(id,N'IsProcedure') = 1)
drop procedure [dbo].[Report_Get_MetroDetailsResos]
GO

CREATE Procedure dbo.Report_Get_MetroDetailsResos
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

select 
		s.*  -- Summary Data

		-- Computed averages; Integer math (avg is a whole number)
		,(case when rest > 0 then IsNull((resos),0) / IsNull((rest),0) 
			else 0 end) as resosPerRest
		,(case when last_rest > 0 then IsNull((last_resos),0) / IsNull((last_rest),0) 
			else 0 end) as last_resosPerRest
		,(case when qtr_rest > 0 then IsNull((qtr_resos),0) / IsNull((qtr_rest),0) 
			else 0 end) as qtr_resosPerRest
		,(case when ytd_rest > 0 then IsNull((ytd_resos),0) / IsNull((ytd_rest),0) 
			else 0 end) as ytd_resosPerRest
		,(case when IsNull((rest),0) > 0 then IsNull((covers),0) / IsNull((rest),0) 
			else 0 end) as coversPerRest
		,(case when IsNull((last_rest),0) > 0 then IsNull((last_covers),0) / IsNull((last_rest),0) 
			else 0 end) as last_coversPerRest
		,(case when IsNull((qtr_rest),0) > 0 then IsNull((qtr_covers),0) / IsNull((qtr_rest),0) 
			else 0 end) as qtr_coversPerRest
		,(case when IsNull((ytd_rest),0) > 0 then IsNull((ytd_covers),0) / IsNull((ytd_rest),0) 
			else 0 end) as ytd_coversPerRest
			
from (
	Select		 t.MetroAreaName as Name
		,Sum(
			case when ReportDate = @fromDate then Resos 
			else 0 end
		) as Resos
		,sum(
			case when ReportDate = @fromDate then Covers 
			else 0 end
		) as covers
		,sum(
			case when ReportDate = @fromDate then Dining 
			else 0 end
		) as dining
		,count(distinct 
			case when ReportDate = @fromDate then ResRPT.RID
			else null end
		) as rest
		,sum(
			case when ReportDate = @lastfromdate then Resos 
			else 0 end
		) as Last_Resos
		,sum(
			case when ReportDate = @lastfromdate then Covers 
			else 0 end
		) as Last_Covers
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
		) as Qtr_Resos
		,sum(
			case when ReportDate >= @qtrfromdate and ReportDate < @qtrEndDate then Covers 
			else 0 end	
		) as Qtr_Covers
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
		) as Ytd_Resos
		,sum(
			case when ReportDate >= @ytdfromdate then Covers 
			else 0 end
		) as Ytd_Covers
		,sum(
			case when ReportDate >= @ytdfromdate then dining 
			else 0 end
		) as Ytd_Dining
		,count(distinct 
			case when ReportDate >= @ytdfromdate then ResRPT.RID
			else null end
		) as ytd_rest	
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
		) as BpNc
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
		) as TNc					
		
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
		) as LastBpNc
		,sum(
			case when ReportDate = @lastfromdate then tfirst 
			else 0 end
		) as Last_tfirst
		,sum(
			case when ReportDate = @lastfromdate then tsecond 
			else 0 end
		) as Lasttsecond
		,sum(
			case when ReportDate = @lastfromdate then TNc 
			else 0 end
		) as LastTNc

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
		) as QtrBpNc
		,sum(
			case when ReportDate >= @qtrfromdate and ReportDate < @qtrEndDate then tfirst 
			else 0 end	
		) as Qtr_tfirst
		,sum(
			case when ReportDate >= @qtrfromdate and ReportDate < @qtrEndDate then tsecond 
			else 0 end	
		) as Qtrtsecond
		,sum(
			case when ReportDate >= @qtrfromdate and ReportDate < @qtrEndDate then TNc 
			else 0 end	
		) as QtrTNc			
		
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
		) as YtdBpNc			
		,sum(
			case when ReportDate >= @ytdfromdate then tfirst 
			else 0 end
		) as Ytd_tfirst
		,sum(
			case when ReportDate >= @ytdfromdate then Tsecond 
			else 0 end
		) as YtdTsecond
		,sum(
			case when ReportDate >= @ytdfromdate then TNc 
			else 0 end
		) as YtDtNc			
	from MetroAreaVW t
	left join	ReportRestaurant on t.MetroAreaID = ReportRestaurant.MetroAreaID
	left join	ReservationRPTSummary ResRPT 
	on			ReportRestaurant.RID = ResRPT.RID
	and			ReportDate between @minDate and @fromDate
	where 		t.MetroAreaID= @metroName
	group by t.MetroAreaName
) s

GO


GRANT EXECUTE ON [Report_Get_MetroDetailsResos] TO ExecuteOnlyRole

GO

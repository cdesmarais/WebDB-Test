if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobReportCalcCallerPointsDiscrepency]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[JobReportCalcCallerPointsDiscrepency]
go

CREATE PROCEDURE dbo.JobReportCalcCallerPointsDiscrepency
As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @curDate datetime
set @curDate = getdate() 

--**********************************************
--** Generate a temp table containing:
--** All Regular Callers (non-annonymous)
--** Who's current point total does not match the calculate point totals derived from al transaction tables
--**********************************************
declare @TempCallerPoints table
(
	CallerID			int,
	Points				int,
	CalcPoints			int,
	LastPointsGainDate	DateTime
)

insert into @TempCallerPoints
Select		ca.CallerID
	       ,ca.Points
	       ,IsNull(Sum(cuscal.ActivityValue),0) as CalcPoints
	       ,ca.LastPointsGainDate
from		Caller ca
left join	
	(select    gr.CallerID
	          ,'Redemption' as ActivityType
	          ,-1*sum(Coalesce(pointsredeemed,0)) as ActivityValue
	from       giftredemption gr
	where	callerid is not null -- only include caller records
	group by   gr.CallerID

	union all
	(select    pa.CallerID
	          ,'Adjustment' as ActivityType
	          ,sum(Coalesce(pa.AdjustmentAmount,0)) as ActivityValue
	from       PointsAdjustment pa
	where	callerid is not null -- only include caller records
	group by   pa.CallerID
	)
	union all
	(select		r.CallerID
				,'Dine' as ActivityType
				,sum(Coalesce(r.ResPoints,0)) as ActivityValue
	from		reservation r with (nolock)
	where		r.CallerID is not null -- only include caller records 
	and			r.RStateID in (2,5,6,7) 
	group by	r.CallerID
	)
	union all
	(select    pu.CallerID
	          ,'Promo' as ActivityType
	          ,sum(Coalesce(pu.points,0)) as ActivityValue
	from       PromoUse pu
	inner join promos p
	on		p.PromoID = pu.PromoID
	where	callerid is not null -- only include caller records
	and		p.promotypeid <> 2 
	group by   pu.CallerID
	)
) as cuscal 
on       ca.CallerID = cuscal.CallerID
where	 LastPointsGainDate < @curDate -- Do not incude Caller that had points modified while this job was running
group by ca.CallerID
		,ca.Points
		,ca.LastPointsGainDate
Having IsNull(Sum(cuscal.ActivityValue),0) <>  IsNull(ca.Points, -1) -- Forces null Callers to always get updated



--**********************************
--** Update the Callers based from generated table
--** Verify the LastPointsGainDate still matches; if not assume a change was made after the temp table was generated
--**********************************

select		tc.*
from		Caller cal
inner join	@TempCallerPoints tc
on			cal.CallerID = tc.CallerID
and			cal.LastPointsGainDate = tc.LastPointsGainDate	--** Assume if dates don't match then points were awarded 
				 											--** between the time the temp table was generated and this update was run
where		IsNull(cal.points,0) != CalcPoints

GO

GRANT EXECUTE ON [JobReportCalcCallerPointsDiscrepency] TO ExecuteOnlyRole
GO
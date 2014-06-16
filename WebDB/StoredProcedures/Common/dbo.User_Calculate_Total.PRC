if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_Calculate_Total]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_Calculate_Total]
GO

CREATE Procedure dbo.User_Calculate_Total

AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @curDate datetime
set @curDate = getdate() 

--**********************************************
--** Generate a temp table containing:
--** All Regular Customers (non-annonymous)
--** Who's current point total does not match the calculate point totals derived from al transaction tables
--**********************************************
declare @TempCustPoints table 
(
	CustID				int,
	Points				int,
	CalcPoints			int,
	LastPointsGainDate	DateTime
)

insert into @TempCustPoints
Select		ca.CustID
	       ,ca.Points
	       ,IsNull(Sum(cuscal.ActivityValue),0) as CalcPoints
	       ,ca.LastPointsGainDate
from		Customer ca
left join	
	(select    gr.CustID
	          ,'Redemption' as ActivityType
	          ,-1*sum(Coalesce(pointsredeemed,0)) as ActivityValue
	from       giftredemption gr
	where	callerid is null -- do not include caller records
	group by   gr.CustID

	union all
	(select    pa.CustID
	          ,'Adjustment' as ActivityType
	          ,sum(Coalesce(pa.AdjustmentAmount,0)) as ActivityValue
	from       PointsAdjustment pa
	where	callerid is null -- do not include caller records
	group by   pa.CustID
	)
	union all
	(select		r.CustID
				,'Dine' as ActivityType
				,sum(Coalesce(r.ResPoints,0)) as ActivityValue
	from		reservation r with (nolock)
	where		r.CallerID is null 
	and			r.RStateID in (2,5,6,7) 
	group by	r.CustID
	)
	union all
	(select    pu.CustID
	          ,'Promo' as ActivityType
	          ,sum(Coalesce(pu.points,0)) as ActivityValue
	from       PromoUse pu
	inner join promos p
	on		p.PromoID = pu.PromoID
	where	callerid is null -- do not include caller records
	and		p.promotypeid <> 2 
	group by   pu.CustID
	)
) as cuscal 
on       ca.CustID = cuscal.CustID
where	 Ca.ConsumerType != 8
and		 LastPointsGainDate < @curDate -- Do not incude customer that had points modified while this job was running
group by ca.CustID
		,ca.Points
		,ca.LastPointsGainDate
Having IsNull(Sum(cuscal.ActivityValue),0) <>  IsNull(ca.Points, -1) -- Forces null customers to always get updated



--**********************************
--** Update the customers based from generated table
--** Verify the LastPointsGainDate still matches; if not assume a change was made after the temp table was generated
--**********************************
Update		Customer
Set			Points = CalcPoints
from		Customer cal
inner join	@TempCustPoints tc
on			cal.custid = tc.custid
and			cal.LastPointsGainDate = tc.LastPointsGainDate	--** Assume if dates don't match then points were awarded 
				 											--** between the time the temp table was generated and this update was run
where		IsNull(cal.points,0) != CalcPoints

--*****************************
--* Log Number of records affected
--*****************************
declare @updatecount int
set @updatecount  = @@rowcount
insert into ErrorLogVW (ErrTimeStamp, ErrSeverity, ErrorId, ErrStackTrace, ErrMsg)
select getdate(), 
		1, 
		@updatecount, 
		'User_Calculate_Total', 
		'Records affected: ' + convert(varchar, @updatecount) 
		
--*******************************
--** Log users identified with point differences; this suggest an issue with the way our point triggers work
--*******************************
insert into ErrorLogVW (ErrTimeStamp, ErrSeverity, ErrorId, ErrStackTrace, ErrMsg)
select getdate(), 
		1, 
		tc.CustID, 
		'User_Calculate_Total', 
		'CustID: ' + convert(varchar, tc.custID) 
		+ ' Points: ' + convert(varchar, tc.Points) 
		+ ' CalcPoints: ' + convert(varchar, tc.CalcPoints) 
		+ ' LastPointsGainDate: ' + convert(varchar, tc.LastPointsGainDate) 
from		Customer cal
inner join	@TempCustPoints tc
on			cal.custid = tc.custid
and			cal.LastPointsGainDate = tc.LastPointsGainDate	
	
GO

GRANT EXECUTE ON [User_Calculate_Total] TO ExecuteOnlyRole

GO

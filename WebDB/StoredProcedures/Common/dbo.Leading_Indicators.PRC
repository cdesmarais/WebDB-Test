if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Leading_Indicators]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Leading_Indicators]
GO

CREATE PROCEDURE dbo.Leading_Indicators
(
  @thrudate datetime = NULL,
  @Area nvarchar(255) = NULL
)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Declare @fromdate datetime
If @thrudate is null
 Begin
 Select @thrudate = getdate()
 End
Select @fromdate = dateadd(m,-1,Cast(@thrudate as datetime))


Select t.MetroAreaName as Name
			,t.MetroAreaID
			,'' as Division
			,sum(case when(ReportType = '3month') Then 1 Else 0 End) as OT3Regs
			,sum(case when(ReportType = '3month') Then cast(Dreward as int) Else 0 End) as OT3Dining
			,sum(case when(ReportType = '3month') Then cast(covers as int) Else 0 End) as OT3Covers
			,sum(case when(ReportType = '6month') Then 1 Else 0 End) as OT6Regs
			,sum(case when(ReportType = '6month') Then cast(Dreward as int) Else 0 End) as OT6Dining
			,sum(case when(ReportType = '6month') Then cast(covers as int) Else 0 End) as OT6Covers
			,sum(case when(ReportType = 'retmonth') Then 1 Else 0 End) as OTretRegs
			,sum(case when(ReportType = 'retmonth') Then cast(Dreward as int) Else 0 End) as OTretDining
			,sum(case when(ReportType = 'retmonth') Then cast(covers as int) Else 0 End) as OTretCovers

from		MetroAreaVW  t
inner join (
	Select r.CustID
			,OTReal.MetroAreaID
			,sum(case when (r.ResPoints > 100)Then (r.ResPoints*.02) else 0 end) as Dreward
			,sum(case when(r.ResPoints <= 100) Then Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End end) as covers,
			'OTCustomer' as CustomerType
			,'3month' as ReportType
	from		reservation r
	inner join	Customer OTReal 
	on			r.CustID = OTReal.CustID
	inner join	Restaurant rt 
	on			r.RID = rt.RID
	inner join	Neighborhood n 
	on			rt.NeighborhoodID = n.NeighborhoodID
	where		r.RStateID not in (3,4,8,9,10) 
	and			datediff(m,r.ShiftDate,@fromdate) between 0 and 2
	and			n.MetroAreaID <> 1 
	and			OTReal.MetroAreaID <> 1
	Group by	r.CustID
				,OTReal.MetroAreaID

	union
	(Select r.CallerID
			,OTCall.MetroAreaID,
			sum(case when (r.ResPoints > 100)Then (r.ResPoints*.02) else 0 end) as Dreward,
			sum(case when(r.ResPoints <= 100) Then Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End end) as covers,
			(Case when(OTCall.PositionID = 2) Then 'Concierge'
				when(OTCall.PositionID = 3) Then 'Admin_Assistant'
				when(OTCall.PositionID = 4) Then 'Travel' Else 'None' End) as CustomerType,
			'3month' as ReportType
	from reservation r
	inner join caller OTCall on r.CallerID = OTCall.CallerID
	inner join Restaurant rt on r.RID = rt.RID
	inner join Neighborhood n on rt.NeighborhoodID = n.NeighborhoodID
	where r.RStateID not in (3,4,8,9,10) and datediff(m,r.ShiftDate,@fromdate) between 0 and 2
	and n.MetroAreaID <> 1 and OTCall.MetroAreaID <> 1
	group by r.CallerID,OTCall.MetroAreaID,OTCall.PositionID
	)
	union(
	Select	r.CustID,
			OTReal.MetroAreaID,
			sum(case when (r.ResPoints > 100)Then (r.ResPoints*.02) else 0 end) as Dreward,	
			sum(case when(r.ResPoints <= 100) Then Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End end) as covers,
			'OTCustomer' as CustomerType
			,'6month' as ReportType
	from reservation r
	inner join Customer OTReal on r.CustID = OTReal.CustID
	inner join Restaurant rt on r.RID = rt.RID
	inner join Neighborhood n on rt.NeighborhoodID = n.NeighborhoodID
	where r.RStateID not in (3,4,8,9,10) and datediff(m,r.ShiftDate,@fromdate) between 3 and 5
	and n.MetroAreaID <> 1 and OTReal.MetroAreaID <> 1
	Group by r.CustID,OTReal.MetroAreaID
	)

	union(
	Select r.CallerID,OTCall.MetroAreaID,
			sum(case when (r.ResPoints > 100)Then (r.ResPoints*.02) else 0 end) as Dreward,
			sum(case when(r.ResPoints <= 100) Then Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End end) as covers,
			(Case when(OTCall.PositionID = 2) Then 'Concierge'
			when(OTCall.PositionID = 3) Then 'Admin_Assistant'
			when(OTCall.PositionID = 4) Then 'Travel' Else 'None' End) as CustomerType,
			'6month' as ReportType
	from reservation r
	inner join caller OTCall on r.CallerID = OTCall.CallerID
	inner join Restaurant rt on r.RID = rt.RID
	inner join Neighborhood n on rt.NeighborhoodID = n.NeighborhoodID
	where r.RStateID not in (3,4,8,9,10) and datediff(m,r.ShiftDate,@fromdate) between 3 and 5
	and n.MetroAreaID <> 1 and OTCall.MetroAreaID <> 1
	group by r.CallerID,OTCall.MetroAreaID,OTCall.PositionID
	)
	union(
	Select r.CustID,OTReal.MetroAreaID,
			sum(case when (r.ResPoints > 100)Then (r.ResPoints*.02) else 0 end) as Dreward,
			sum(case when(r.ResPoints <= 100) Then Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End end) as covers,
			'OTCustomer' as CustomerType
			,'retmonth' as ReportType
	from reservation r
	inner join Customer OTReal on r.CustID = OTReal.CustID
	inner join Restaurant rt on r.RID = rt.RID
	inner join Neighborhood n on rt.NeighborhoodID = n.NeighborhoodID
	where r.RStateID not in(3,4,8,9,10) and datediff(m,r.ShiftDate,@fromdate) between 0 and 2
	and n.MetroAreaID <> 1 and OTReal.CustID
	in	(Select distinct(r.CustID)
		from reservation r
		inner join Customer OTReal on r.CustID = OTReal.CustID
		inner join Restaurant rt on r.RID = rt.RID
		inner join Neighborhood n on rt.NeighborhoodID = n.NeighborhoodID
		where r.RStateID not in (3,4,8,9,10) and datediff(m,r.ShiftDate,@fromdate) between 3 and 5
		and n.MetroAreaID <> 1
		) 
	and OTReal.MetroAreaID <> 1
	Group By r.CustID,OTReal.MetroAreaID
	)
	union
	(
	Select r.CallerID,OTCall.MetroAreaID,
			sum(case when (r.ResPoints > 100)Then (r.ResPoints*.02) else 0 end) as Dreward,
			sum(case when(r.ResPoints <= 100) Then Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End end) as covers,
			(Case when(OTCall.PositionID = 2) Then 'Concierge'
			when(OTCall.PositionID = 3) Then 'Admin_Assistant'
			when(OTCall.PositionID = 4) Then 'Travel' Else 'None' End) as CustomerType,
			'retmonth' as ReportType
	from reservation r
	inner join caller OTCall on r.CallerID = OTCall.CallerID
	inner join Restaurant rt on r.RID = rt.RID
	inner join Neighborhood n on rt.NeighborhoodID = n.NeighborhoodID
	where r.RStateID not in(3,4,8,9,10) and datediff(m,r.ShiftDate,@fromdate) between 0 and 2
	and n.MetroAreaID <> 1 and OTCall.CallerID
	in	(Select distinct(r.CallerID)
		from reservation r
		inner join caller OTCall on r.CallerID = OTCall.CallerID
		inner join Restaurant rt on r.RID = rt.RID
		inner join Neighborhood n on rt.NeighborhoodID = n.NeighborhoodID
		where r.RStateID not in (3,4,8,9,10) and datediff(m,r.ShiftDate,@fromdate) between 3 and 5
		and n.MetroAreaID <> 1
		) 
	and OTCall.MetroAreaID <> 1
	Group By r.CallerID
	,OTCall.MetroAreaID
	,OTCall.PositionID
	)
) as CustTable 
on t.MetroAreaID = CustTable.MetroAreaID
group by t.MetroAreaID
,t.MetroAreaName
order by OT3Regs desc

GO


GRANT EXECUTE ON [Leading_Indicators] TO ExecuteOnlyRole

GO

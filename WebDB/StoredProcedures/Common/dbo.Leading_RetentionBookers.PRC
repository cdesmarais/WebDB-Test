if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Leading_RetentionBookers]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Leading_RetentionBookers]
GO

CREATE PROCEDURE dbo.Leading_RetentionBookers
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


Select territories.MetroName as Name
, territories.MetroAreaID
, territories.Division,
sum(case when(CustomerType = 'OTCustomer') Then 1 Else 0 End) as OTretRegs,
sum(case when(CustomerType = 'OTCustomer') Then cast(Dreward as int) Else 0 End) as OTretDining,
sum(case when(CustomerType = 'OTCustomer') Then cast(covers as int) Else 0 End) as OTretCovers,
sum(case when(CustomerType = 'Concierge') Then 1 Else 0 End) as CretRegs,
sum(case when(CustomerType = 'Concierge') Then cast(Dreward as int) Else 0 End) as CretDining,
sum(case when(CustomerType = 'Concierge') Then cast(covers as int) Else 0 End) as CretCovers,
sum(case when(CustomerType = 'Admin_Assistant') Then 1 Else 0 End) as AAretRegs,
sum(case when(CustomerType = 'Admin_Assistant') Then cast(Dreward as int) Else 0 End) as AAretDining,
sum(case when(CustomerType = 'Admin_Assistant') Then cast(covers as int) Else 0 End) as AAretCovers,
sum(case when(CustomerType = 'Travel') Then 1 Else 0 End) as TretRegs,
sum(case when(CustomerType = 'Travel') Then cast(Dreward as int) Else 0 End) as TretDining,
sum(case when(CustomerType = 'Travel') Then cast(covers as int) Else 0 End) asTretCovers
from territories
left join(Select r.CustID, OTReal.MetroAreaID,
sum(case when (r.ResPoints > 100)Then (r.ResPoints*.02) else 0 end) as Dreward,
sum(case when(r.ResPoints <= 100) Then Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End end) as covers,
'OTCustomer' as CustomerType
from reservation r
inner join Customer OTReal on r.CustID = OTReal.CustID
inner join Restaurant rt on r.RID = rt.RID
inner join Neighborhood n on rt.NeighborhoodID = n.NeighborhoodID
where r.RStateID not in (3,4,8,9,10) and datediff(m,r.ShiftDate,@fromdate) between 0 and 2
and n.MetroAreaID <> 1 and OTReal.CustID
in(Select distinct(r.CustID)
from reservation r
inner join Customer OTReal on r.CustID = OTReal.CustID
inner join Restaurant rt on r.RID = rt.RID
inner join Neighborhood n on rt.NeighborhoodID = n.NeighborhoodID
where r.RStateID not in (3,4,8,9,10) and datediff(m,r.ShiftDate,@fromdate) between 3 and 5
and n.MetroAreaID <> 1)
Group By r.CustID, OTReal.MetroAreaID
union(
Select r.CallerID
, OTCall.MetroAreaID
,sum(case when (r.ResPoints > 100)Then (r.ResPoints*.02) else 0 end) as Dreward
,sum(case when(r.ResPoints <= 100) Then Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End end) as covers
,(Case when(OTCall.PositionID = 2) Then 'Concierge'
when(OTCall.PositionID = 3) Then 'Admin_Assistant'
when(OTCall.PositionID = 4) Then 'Travel' Else 'None' End) as CustomerType
from reservation r
inner join caller OTCall on r.CallerID = OTCall.CallerID
inner join Restaurant rt on r.RID = rt.RID
inner join Neighborhood n on rt.NeighborhoodID = n.NeighborhoodID
where r.RStateID not in (3,4,8,9,10) and datediff(m,r.ShiftDate,@fromdate) between 0 and 2
and n.MetroAreaID <> 1 and OTCall.CallerID
in(Select distinct(r.CallerID)
from reservation r
inner join caller OTCall on r.CallerID = OTCall.CallerID
inner join Restaurant rt on r.RID = rt.RID
inner join Neighborhood n on rt.NeighborhoodID = n.NeighborhoodID
where r.RStateID not in (3,4,8,9,10) and datediff(m,r.ShiftDate,@fromdate) between 3 and 5
and n.MetroAreaID <> 1)
Group By r.CallerID, OTCall.MetroAreaID, OTCall.PositionID)) as CustTable 
on territories.MetroAreaID = CustTable.MetroAreaID
group by territories.MetroAreaID
, territories.Division
, territories.MetroName
order by territories.MetroName

GO


GRANT EXECUTE ON [Leading_RetentionBookers] TO ExecuteOnlyRole

GO

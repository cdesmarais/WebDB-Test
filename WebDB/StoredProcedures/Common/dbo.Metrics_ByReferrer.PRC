GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Metrics_ByReferrer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Metrics_ByReferrer]
GO



CREATE PROCEDURE dbo.Metrics_ByReferrer
(
  @thrudate datetime = NULL
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


Select OTRef.ReferrerID
, OTRef.ReferrerName,
sum(case when(ReportType = 'ActiveBookers') Then 1 Else 0 End) as OT3Regs,
sum(case when(ReportType = 'ActiveBookers') Then cast(resos as int) Else 0 End) as OT3Resos,
sum(case when(ReportType = 'ActiveBookers') Then cast(Dreward as int) Else 0 End) as OT3Dining,
sum(case when(ReportType = 'ActiveBookers') Then cast(covers as int) Else 0 End) as OT3Covers,
sum(case when(ReportType = 'AllRefRegs') Then 1 Else 0 End) as AllRefRegs,
sum(case when(ReportType = 'Conversion') Then 1 Else 0 End) as ConversionRegs
from referrer OTRef
left join(
Select r.CustID
, OTReal.MetroAreaID,
count(r.ResID) as resos
,sum(case when (r.ResPoints > 100)Then (r.ResPoints*.02) else 0 end) as DReward
,sum(case when(r.ResPoints <= 100) Then Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End end) as covers,
'ActiveBookers' as ReportType
, 'OTReal' as member_type
, ReferrerID
from reservation r
inner join ReferrerRegistration OTRefReg 
on r.CustID = OTRefReg.CustID
inner join Customer OTReal 
on OTRefReg.CustID = OTReal.CustID
inner join Restaurant rt 
on r.RID = rt.RID
inner join Neighborhood n 
on rt.NeighborhoodID = n.NeighborhoodID
where r.RStateID not in (3,4,8,9,10) and datediff(m,r.ShiftDate,@fromdate) between 0 and 2
and n.MetroAreaID <> 1
Group by r.CustID, OTReal.MetroAreaID, ReferrerID

union(Select r.CallerID, OTCall.MetroAreaID,
count(r.ResID) as resos,
sum(case when (r.ResPoints > 100)Then (r.ResPoints*.02) else 0 end) as DReward,
sum(case when(r.ResPoints <= 100) Then Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End end) as covers,
'ActiveBookers' as ReportType
, 'OTCall' as member_type
, ReferrerID
from reservation r
inner join ReferrerRegistration OTRefReg 
on r.CallerID = OTRefReg.CallerID
inner join caller OTCall 
on OTRefReg.CallerID = OTcall.CallerID
inner join Restaurant rt 
on r.RID = rt.RID
inner join Neighborhood n 
on rt.NeighborhoodID = n.NeighborhoodID
where r.RStateID not in (3,4,8,9,10) and datediff(m,r.ShiftDate,@fromdate) between 0 and 2
and n.MetroAreaID <> 1 and OTRefReg.CallerID is not null
Group by r.CallerID, OTCall.MetroAreaID, ReferrerID)

union(Select OTReal.CustID
, OTReal.MetroAreaID
,NULL as resos
,NULL as Dreward
,NULL as covers
, 'AllRefRegs' as ReportType
, 'OTReal' as member_type
, ReferrerID
from Customer OTReal
inner join ReferrerRegistration OTRefReg on OTReal.CustID = OTRefReg.CustID
where datediff(m,OTReal.CreateDate,@fromdate) between 0 and 2 and email not like '%opentable.com%'
and OTRefReg.CustID is not null
Group By OTReal.CustID, OTReal.MetroAreaID, ReferrerID)


union(Select OTCall.CallerID
, OTCall.MetroAreaID
,NULL as resos
,NULL as Dreward
,NULL as covers
, 'AllRefRegs' as ReportType
, 'OTCall' as member_type
, ReferrerID
from caller OTCall
inner join ReferrerRegistration OTRefReg on OTCall.CallerID = OTRefReg.CallerID
where datediff(m,OTCall.createdate,@fromdate) between 0 and 2 and email not like '%opentable.com%'
and OTRefReg.CallerID is not null
Group By OTCall.CallerID, OTCall.MetroAreaID, ReferrerID)


union(Select OTReal.CustID
, OTReal.MetroAreaID
,NULL as resos
,NULL as Dreward
,NULL as covers
, 'Conversion' as ReportType
, 'OTReal' as member_type
, ReferrerID
from Customer OTReal
inner join ReferrerRegistration OTRefReg on OTReal.CustID = OTRefReg.CustID
where datediff(m,OTReal.CreateDate,@fromdate) between 0 and 2 and email not like '%opentable.com%'

Group By OTReal.CustID, OTReal.MetroAreaID, ReferrerID)

union(Select OTCall.CallerID
, OTCall.MetroAreaID
,NULL as resos
,NULL as Dreward
,NULL as covers
, 'Conversion' as ReportType
, 'OTCall' as member_type
, ReferrerID
from caller OTCall
inner join ReferrerRegistration OTRefReg 
on OTCall.CallerID = OTRefReg.CallerID
where datediff(m,OTCall.createdate,@fromdate) between 0 and 2 and email not like '%opentable.com%'

Group By OTCall.CallerID
, OTCall.MetroAreaID
, ReferrerID)) as CustTable 
on OTRef.ReferrerID = CustTable.ReferrerID
group by OTRef.ReferrerID
, OTRef.ReferrerName

order by OTRef.ReferrerID asc



GO


GRANT EXECUTE ON [Metrics_ByReferrer] TO ExecuteOnlyRole

GO

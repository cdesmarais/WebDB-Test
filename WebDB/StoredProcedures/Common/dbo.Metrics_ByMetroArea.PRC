if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Metrics_ByMetroArea]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Metrics_ByMetroArea]
GO

CREATE PROCEDURE dbo.Metrics_ByMetroArea
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

Select ma.MetroAreaID
, ma.MetroAreaName as MetroName
, OTRef.ReferrerID, OTRef.Name
,sum(case when(ReportType = 'Regs') Then 1 Else 0 End) as Regs
,sum(case when(ReportType = 'Resos') Then 1 Else 0 End) as Resos
from MetroArea ma
inner join (
Select OTReal.CustID
, OTReal.MetroAreaID
, 'Regs' as ReportType
, 'OTReal' as member_type
, ReferrerID
from Customer OTReal
inner join ReferrerRegistration OTRefReg 
on OTReal.CustID = OTRefReg.CustID
where datediff(m,OTReal.CreateDate,@fromdate) = 0 
and email not like '%opentable.com%'
and OTRefReg.CustID is not null
Group By OTReal.CustID
, OTReal.MetroAreaID
, ReferrerID


union(
Select OTCall.CallerID, OTCall.MetroAreaID
, 'Regs' as ReportType
, 'OTCall' as member_type
, ReferrerID
from caller OTCall
inner join ReferrerRegistration OTRefReg on OTCall.CallerID = OTRefReg.CallerID
where datediff(m,OTCall.createdate,@fromdate) = 0 and email not like '%opentable.com%'
and OTRefReg.CallerID is not null
Group By OTCall.CallerID, OTCall.MetroAreaID, ReferrerID)

union(
Select OTRefRes.ResID
, n.MetroAreaID
, 'Resos' as ReportType
,NULL as member_type
, OTRefRes.ReferrerID
from reservation r
inner join referrer_reservation OTRefRes 
on r.ResID = OTRefRes.ResID
inner join referrer OTRef 
on OTRefRes.ReferrerID = OTRef.ReferrerID
inner join Restaurant rt 
on r.RID = rt.RID
inner join Neighborhood n 
on rt.NeighborhoodID = n.NeighborhoodID
where r.RStateID not in (3,4,8,9,10) 
and datediff(m,r.ShiftDate,@fromdate) = 0
and n.MetroAreaID <> 1)
)as CustTable 
on ma.MetroAreaID = CustTable.MetroAreaID
inner join referrer OTRef 
on CustTable.ReferrerID = OTRef.ReferrerID
group by ma.MetroAreaID
, ma.MetroAreaName
, OTRef.ReferrerID
, OTRef.Name
order by ma.MetroAreaName asc

GO


GRANT EXECUTE ON [Metrics_ByMetroArea] TO ExecuteOnlyRole

GO

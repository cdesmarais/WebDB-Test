if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Metrics_ResosByReferrer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Metrics_ResosByReferrer]
GO

CREATE PROCEDURE dbo.Metrics_ResosByReferrer
(
  @thrudate datetime = NULL
)
AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

Declare @fromdate datetime
If @thrudate is null
 Begin
 Select @thrudate = getdate()
 End
Select @fromdate = dateadd(m,-1,Cast(@thrudate as datetime))

Select	 OTRef.ReferrerID
	,OTRef.ReferrerName
	,count(resos) as resos
	,sum(coalesce(covers,0)) as covers
from	 referrer OTRef
left join	(Select  OTRefRes.ReferrerID
			,n.MetroAreaID
			,OTRefRes.ResID as resos
			,Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End as covers
		from	 reservation r
		inner join ReferrerReservationVW OTRefRes 
		on	r.ResID = OTRefRes.ResID
		inner join referrer OTRef 
		on	OTRefRes.ReferrerID = OTRef.ReferrerID
		inner join Restaurant rt 
		on	r.RID = rt.RID
		inner join Neighborhood n 
		on	rt.NeighborhoodID = n.NeighborhoodID
		where r.RStateID not in (3,4,8,9,10) 
		and	datediff(m,r.ShiftDate,@fromdate) between 0 and 2
		and	n.MetroAreaID <> 1
		)as CustTable 
on OTRef.ReferrerID = CustTable.ReferrerID
group by	OTRef.ReferrerID
		,OTRef.ReferrerName
order by	OTRef.ReferrerID asc

GO


GRANT EXECUTE ON [Metrics_ResosByReferrer] TO ExecuteOnlyRole

GO

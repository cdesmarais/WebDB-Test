if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Leading_3MonthBookers]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Leading_3MonthBookers]
GO

CREATE PROCEDURE dbo.Leading_3MonthBookers
(
  @thrudate datetime = NULL
  ,@Area nvarchar(255) = NULL
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


Select	t.MetroName as Name
	,t.MetroAreaID
	,t.Division
	,sum(case when(CustomerType = 'OTCustomer')		Then 1 Else 0 End) as OT3Regs
	,sum(case when(CustomerType = 'OTCustomer')		Then cast(Dreward as int) Else 0 End) as OT3Dining
	,sum(case when(CustomerType = 'OTCustomer')		Then cast(covers as int) Else 0 End) as OT3Covers
	,sum(case when(CustomerType = 'Concierge')		Then 1 Else 0 End) as C3Regs
	,sum(case when(CustomerType = 'Concierge')		Then cast(Dreward as int) Else 0 End) as C3Dining
	,sum(case when(CustomerType = 'Concierge')		Then cast(covers as int) Else 0 End) as C3Covers
	,sum(case when(CustomerType = 'Admin_Assistant')	Then 1 Else 0 End) as AA3Regs
	,sum(case when(CustomerType = 'Admin_Assistant')	Then cast(Dreward as int) Else 0 End) as AA3Dining
	,sum(case when(CustomerType = 'Admin_Assistant')	Then cast(covers as int) Else 0 End) as AA3Covers
	,sum(case when(CustomerType = 'Travel')		Then 1 Else 0 End) as T3Regs
	,sum(case when(CustomerType = 'Travel')		Then cast(Dreward as int) Else 0 End) as T3Dining
	,sum(case when(CustomerType = 'Travel')		Then cast(covers as int) Else 0 End) as T3Covers
from	territories t
left join	(Select r.CustID
			,OTReal.MetroAreaID 'MetroAreaID'
			,sum(case when (r.ResPoints > 100)Then (r.ResPoints*.02) else 0 end) as Dreward
			,sum(case when(r.ResPoints <= 100) Then Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End end) as covers
			,'OTCustomer' as CustomerType
	from		reservation r
	inner join	Customer OTReal 
	on		r.CustID = OTReal.CustID
	inner join	Restaurant rt 
	on		r.RID = rt.RID
	inner join	neighborhood n 
	on		rt.NeighborhoodID = n.NeighborhoodID
	where		r.RStateID not in (3,4,8,9,10)
	and		datediff(m,r.ShiftDate,@fromdate) between 0 and 2
	and		n.MetroAreaID <> 1
	Group by	r.CustID
	,OTReal.MetroAreaID
	union
	(Select		 r.CallerID
			,OTCall.MetroAreaID 
			,sum(case when (r.ResPoints > 100)Then (r.ResPoints*.02) else 0 end) as Dreward
			,sum(case when(r.ResPoints <= 100) Then Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End end) as covers
			,(Case  when(OTCall.PositionID = 2) Then 'Concierge'
				when(OTCall.PositionID = 3) Then 'Admin_Assistant'
				when(OTCall.PositionID = 4) Then 'Travel' Else 'None' End) as CustomerType
	from		reservation r
	inner join	caller OTCall 
	on		r.CallerID = OTCall.CallerID
	inner join	Restaurant rt 
	on		r.RID = rt.RID
	inner join	neighborhood n 
	on		rt.NeighborhoodID = n.NeighborhoodID
	where		r.RStateID not in (3,4,8,9,10)
	and		datediff(m,r.ShiftDate,@fromdate) between 0 and 2
	and		n.MetroAreaID <> 1
	group by	r.CallerID
			,OTCall.MetroAreaID
			,OTCall.PositionID)
	) as CustTable 
on	 t.MetroAreaID = CustTable.MetroAreaID
group by t.Division
	,t.MetroAreaID
	,t.MetroName
order by t.MetroName
 
GO


GRANT EXECUTE ON [Leading_3MonthBookers] TO ExecuteOnlyRole

GO

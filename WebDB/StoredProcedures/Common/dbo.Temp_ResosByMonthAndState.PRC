if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Temp_ResosByMonthAndState]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Temp_ResosByMonthAndState]
GO

CREATE PROCEDURE dbo.Temp_ResosByMonthAndState
(
  @strDateOffset int
 ,@ResoState int
 ,@Area nvarchar(255) = NULL
)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


Select	 t.MetroName as Name
	,t.MetroAreaID
	,sum(case when(CustTable.CustomerType = 'OTCustomer') Then 1 Else 0 End) as OTretRegs
	,sum(case when(CustTable.CustomerType = 'Concierge') Then 1 Else 0 End) as CretRegs
	,sum(case when(CustTable.CustomerType = 'Admin_Assistant') Then 1 Else 0 End) as AAretRegs
	,sum(case when(CustTable.CustomerType = 'Travel') Then 1 Else 0 End) as TretRegs
from	territories t
left join	(Select   r.CustID
		         ,OTReal.MetroAreaID 'MetroAreaID'
		         ,'OTCustomer' as CustomerType
		from       Reservation r
		inner join Customer OTReal 
		on         r.CustID = OTReal.CustID
		inner join Restaurant rt 
		on	   r.RID = rt.RID
		inner join Neighborhood n 
		on         rt.NeighborhoodID = n.NeighborhoodID
		where      r.RStateID = @ResoState 
		and        datediff(m,r.ShiftDate,(getdate()-@strDateOffset)) = 0
		and        n.MetroAreaID <> 1 

		union
		(Select    r.CallerID
			  ,coalesce(OTCall.MetroAreaID,4) 'MetroAreaID'
			  ,(Case  when(OTCall.PositionID = 2) Then 'Concierge'
			          when(OTCall.PositionID = 3) Then 'Admin_Assistant'
			          when(OTCall.PositionID = 4) Then 'Travel' Else 'None' End) as CustomerType
		from       Reservation r
		inner join Caller OTCall 
		on         r.CallerID = OTCall.CallerID
		inner join Restaurant rt 
		on         r.RID = rt.RID
		inner join Neighborhood n 
		on         rt.NeighborhoodID = n.NeighborhoodID
		where      r.RStateID = @ResoState 
		and        datediff(m,r.ShiftDate,(getdate()-@strDateOffset)) = 0
		and        n.MetroAreaID <> 1)
		) as CustTable
on	 t.MetroAreaID = CustTable.MetroAreaID
group by t.MetroAreaID
	,t.MetroName
order by t.MetroName


GO


GRANT EXECUTE ON [Temp_ResosByMonthAndState] TO ExecuteOnlyRole

GO

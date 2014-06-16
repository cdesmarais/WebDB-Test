if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUserAddPoints]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUserAddPoints]
GO

CREATE PROCEDURE dbo.DNUserAddPoints
  @CustomerID int=0,
  @IsCaller int=0,
  @Points int,
  @Reason int
AS
if @IsCaller = 0
  Begin
  Update Customer
  Set Points = Points + @points
  Where CustID=@CustomerID
   Insert Into PointsAdjustment(CustID,AdjustmentAmount,AdjReasonID)
   Values(@CustomerID,@points,@Reason)
  Return(0)
  End
if @IsCaller > 0
  Begin
  Update Caller
  Set Points = Points + @points
  Where CallerID=@CustomerID
   Insert Into PointsAdjustment(CallerID,AdjustmentAmount,AdjReasonID)
   Values(@CustomerID,@points,@Reason)
  Return(1)
  End
GO


GRANT EXECUTE ON [DNUserAddPoints] TO ExecuteOnlyRole

GO

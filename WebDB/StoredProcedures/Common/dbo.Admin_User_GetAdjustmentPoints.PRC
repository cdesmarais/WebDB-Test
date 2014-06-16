if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_User_GetAdjustmentPoints]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_User_GetAdjustmentPoints]
GO




CREATE PROCEDURE dbo.Admin_User_GetAdjustmentPoints
(
    @CustomerID int=0,
    @CallerID int=0,
    @Reason int
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
if @CallerID = 0
    Begin
    select AdjustmentAmount from PointsAdjustment where CustID = @CustomerID and AdjReasonID = @Reason
    End
if @CallerID > 0
    Begin
    Select AdjustmentAmount from PointsAdjustment where CallerID = @CallerID and AdjReasonID = @Reason
    End
GO

GRANT EXECUTE ON [Admin_User_GetAdjustmentPoints] TO ExecuteOnlyRole

GO

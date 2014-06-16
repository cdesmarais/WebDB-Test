if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Caller_DeductPointsForNoShow]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Caller_DeductPointsForNoShow]
GO




CREATE PROCEDURE dbo.Caller_DeductPointsForNoShow
(
@CallerID int
)

AS
SET NOCOUNT ON
declare @pointsadjusted int

select @pointsadjusted = ((points/2) - points) from Caller
where CallerID = @CallerID

update Caller set points = points/2 
where CallerID = @CallerID

insert into PointsAdjustment (CallerID,AdjustmentAmount,AdjReasonID)
values (@CallerID,@pointsadjusted,1)
GO

GRANT EXECUTE ON [Caller_DeductPointsForNoShow] TO ExecuteOnlyRole

GO

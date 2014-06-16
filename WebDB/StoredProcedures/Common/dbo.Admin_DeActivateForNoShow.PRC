if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_DeActivateForNoShow]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_DeActivateForNoShow]
GO




CREATE PROCEDURE dbo.Admin_DeActivateForNoShow
(@CallerID int
)
 AS
 SET NOCOUNT ON

declare @points int
select @points = points from Caller where CallerID = @CallerID

update Caller set callerstatusid = 3 --disabled for no show
 where CallerID = @CallerID


--update Caller set email = 'DeActivatedForNoShow' + email where CallerID = @CallerID

--save points in PointsAdjustment table?

Exec dbo.DNLogDeActivatedUsers @CallerID, 1, 1

GO

GRANT EXECUTE ON [Admin_DeActivateForNoShow] TO ExecuteOnlyRole

GO

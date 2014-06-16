if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Caller_DeActivateForNoShow]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Caller_DeActivateForNoShow]
GO




CREATE PROCEDURE dbo.Caller_DeActivateForNoShow
(
@CallerID int
)

 AS
 SET NOCOUNT ON

update Caller set callerstatusid = 3--Disabled For No-Show
where CallerID = @CallerID and PositionID = 3

Exec dbo.DNLogDeActivatedUsers @CallerID, 1, 1

GO

GRANT EXECUTE ON [Caller_DeActivateForNoShow] TO ExecuteOnlyRole

GO

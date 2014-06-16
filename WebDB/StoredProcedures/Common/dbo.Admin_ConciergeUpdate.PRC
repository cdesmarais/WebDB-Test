if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ConciergeUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ConciergeUpdate]
GO




CREATE PROCEDURE dbo.Admin_ConciergeUpdate

(@Caller_Status_ID int,
 @Caller_ID int
 )

AS
SET NOCOUNT ON

BEGIN TRANSACTION
update Caller set callerstatusid = @Caller_Status_ID where CallerID = @Caller_ID
if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)

GO

GRANT EXECUTE ON [Admin_ConciergeUpdate] TO ExecuteOnlyRole

GO

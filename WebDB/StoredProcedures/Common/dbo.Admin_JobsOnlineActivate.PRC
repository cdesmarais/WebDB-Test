if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_JobsOnlineActivate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_JobsOnlineActivate]
GO

CREATE PROCEDURE dbo.Admin_JobsOnlineActivate

(@Job_active bit,
 @Job_ID int
 )

AS
SET NOCOUNT ON

BEGIN TRANSACTION

update JobsOnline 
set JobActive = @Job_active 
where JobID = @Job_ID

if (@@ERROR <> 0)
goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
ROLLBACK TRANSACTION
Return(0)

GO

GRANT EXECUTE ON [Admin_JobsOnlineActivate] TO ExecuteOnlyRole

GO

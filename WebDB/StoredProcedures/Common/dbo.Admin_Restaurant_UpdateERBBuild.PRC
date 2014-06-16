if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_UpdateERBBuild]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_UpdateERBBuild]
GO




CREATE PROCEDURE dbo.Admin_Restaurant_UpdateERBBuild
(
  @RestID int,
  @build int
)
AS

BEGIN TRANSACTION
Update ERBRestaurant
Set ERBBuild = @build
Where RID = @RestID

if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Admin_Restaurant_UpdateERBBuild] TO ExecuteOnlyRole

GO

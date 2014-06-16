if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Delete_StateAreaListing]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Delete_StateAreaListing]
GO

CREATE Procedure dbo.Admin_Delete_StateAreaListing
(	
	@AreaID AS INT 	
)

AS
SET NOCOUNT ON
SET TRAN ISOLATION LEVEL SERIALIZABLE


BEGIN TRAN

	DELETE	dbo.StateAreaListing
	WHERE	AreaID = @AreaID
	
	if (@@ERROR <> 0)
		goto general_error

COMMIT TRAN
RETURN(0)


general_error:
ROLLBACK TRANSACTION
RETURN(1)
GO


GRANT EXECUTE ON [Admin_Delete_StateAreaListing] TO ExecuteOnlyRole

GO



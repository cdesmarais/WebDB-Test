if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Update_StateAreaListing]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Update_StateAreaListing]
GO

CREATE Procedure dbo.Admin_Update_StateAreaListing
(	
	@AreaID AS int
	,@StateID AS NCHAR(2)
	,@MacroID as int
	,@MetroAreaID as int
	,@AreaSection as NVARCHAR(50)
	,@IsFeatured AS BIT
	,@ShortName AS NVARCHAR(50)
	
)

AS
SET NOCOUNT ON
SET TRAN ISOLATION LEVEL SERIALIZABLE

BEGIN TRAN

	UPDATE	dbo.StateAreaListing
	SET		MacroID = @MacroID
			,MetroAreaID = @MetroAreaID
			,AreaSection = @AreaSection
			,IsFeatured = @IsFeatured
			,ShortName = @ShortName
			,StateID = @StateID
	WHERE	AreaID = @AreaID

	if (@@ERROR <> 0)
		goto general_error


COMMIT TRAN
RETURN(0)


general_error:
ROLLBACK TRANSACTION
RETURN(1)
GO

GRANT EXECUTE ON [Admin_Update_StateAreaListing] TO ExecuteOnlyRole
GO


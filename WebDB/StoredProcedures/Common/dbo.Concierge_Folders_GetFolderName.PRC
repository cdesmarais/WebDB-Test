if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Folders_GetFolderName]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Folders_GetFolderName]
GO



CREATE PROCEDURE dbo.Concierge_Folders_GetFolderName
 (
  @FolderID int
 )
As
SET NOCOUNT ON
BEGIN TRANSACTION

Select FolderName as Folder_Name from FavoritesFolder where FFolderID = @FolderID
if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Concierge_Folders_GetFolderName] TO ExecuteOnlyRole

GO

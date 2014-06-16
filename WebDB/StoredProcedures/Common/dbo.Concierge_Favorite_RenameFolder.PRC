if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Favorite_RenameFolder]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Favorite_RenameFolder]
GO



CREATE PROCEDURE dbo.Concierge_Favorite_RenameFolder
 (
  @FolderID int,
  @FolderName nvarchar(255)
 )
As
SET NOCOUNT ON
UPDATE FavoritesFolder
SET FolderName = @FolderName
WHERE FFolderID =  @FolderID
GO

GRANT EXECUTE ON [Concierge_Favorite_RenameFolder] TO ExecuteOnlyRole

GO

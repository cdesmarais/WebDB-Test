if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Folders_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Folders_Add]
GO



CREATE PROCEDURE dbo.Concierge_Folders_Add
 (
  @UserID int,
  @GeoID int,
  @Restaurants nvarchar(1999),
  @FolderName nvarchar(50)
 )
As
SET NOCOUNT ON
BEGIN TRANSACTION
declare @i int
declare @folderid int

INSERT INTO FavoritesFolder
 (
  FolderName,UserID,isCaller,MetroID
 )
VALUES
 (
  @FolderName,@UserID,1,@GeoID
 )

set @folderid = scope_identity()
if (@@ERROR <> 0)
	goto general_error
if (@Restaurants is not null)
BEGIN
	if right(@Restaurants,1) <> ',' select @Restaurants= @Restaurants + ','

	while 1=1
	begin
		select @i= charindex(',',@Restaurants)
		if @i = 0 break
		insert into CallerRestaurants(CallerID,FolderID,RID)
		select @UserID,@folderid,convert(int,substring(@Restaurants,1,@i - 1))
		select @Restaurants= substring(@Restaurants,@i + 1,999)
	end
END
if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Concierge_Folders_Add] TO ExecuteOnlyRole

GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GroupAddRestaurant]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GroupAddRestaurant]
GO


CREATE Procedure dbo.GroupAddRestaurant
(
 @RestaurantID int,
 @GroupName nvarchar(255)
)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Declare @GID int

Select @GID = coalesce(GID,0) from RestaurantGroup where GroupName = @GroupName

if (@GID = 0) or (@GID is null)
BEGIN
	insert into RestaurantGroup (GroupName) VALUES (@GroupName)
	Select @GID = scope_identity()
END

if not exists(Select RID from restaurantToGroup where RID = @RestaurantID)
BEGIN
	insert into restaurantToGroup (GID,RID) VALUES (@GID,@RestaurantID)
END
GO


GRANT EXECUTE ON [GroupAddRestaurant] TO ExecuteOnlyRole

GO

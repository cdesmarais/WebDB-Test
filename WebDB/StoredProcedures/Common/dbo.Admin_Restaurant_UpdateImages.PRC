if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_UpdateImages]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_UpdateImages]
GO

CREATE Procedure dbo.Admin_Restaurant_UpdateImages
(
    @RestaurantID int,
    @Image nvarchar(100),
    @logo nvarchar(100) 
)

As
/* 
Purpose : @SetImage decides the value of 'ShowImage' flag depending on the value of @Image parameter
*/
Declare	@SetImage as int =0
Declare @Thumbnail as nvarchar(20)

SET NOCOUNT ON

BEGIN TRANSACTION

/*
If @Image <> '0' i.e if user requested to show profile image then ShowImage Flag needs to set to 1 otherwise 0.
*/
if @Image <> '0'
BEGIN
    Set @SetImage=1
END


Select @Thumbnail = cast(@RestaurantID as nvarchar) + '.jpg'

if exists (select rid from restaurantimage where rid = @RestaurantID) 
BEGIN
	Update RestaurantImage
	set ShowImage = @SetImage,
	ImageName = @Image,
	Logo = @logo,
	Thumbnail	= @Thumbnail,
	ThumbnailName	= @Thumbnail
	where rid = @RestaurantID
END
else
BEGIN
insert into RestaurantImage (RID,ShowImage,ImageName,Logo,Thumbnail,ThumbnailName)
VALUES (@RestaurantID,@SetImage,@Image,@logo,@Thumbnail,@Thumbnail)
END


if @@error <> 0
	goto error

COMMIT TRANSACTION
Return(0)

error:
	ROLLBACK TRANSACTION
	Return(0)

GO

GRANT EXECUTE ON [Admin_Restaurant_UpdateImages] TO ExecuteOnlyRole

GO

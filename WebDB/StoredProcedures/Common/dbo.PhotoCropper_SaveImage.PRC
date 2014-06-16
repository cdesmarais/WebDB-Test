


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PhotoCropper_SaveImage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PhotoCropper_SaveImage]
go

create Procedure dbo.PhotoCropper_SaveImage
(	
	@RID int	
	,@Image image
)	
as


/* 
	This stored procedure to Store Cropper tool images in database.
	Content owned by India team, please notify asaxena@opentable.com if changing.
*/

	insert into	
		PhotoCropperImages
		(
			RID
			,CroppedImage
			,ModifiedDTUTC 
		)
	values
		(
			@RID
			,@Image
			,getUTCDate()
		)

	select SCOPE_IDENTITY()

go

grant execute on [PhotoCropper_SaveImage] TO ExecuteOnlyRole

go




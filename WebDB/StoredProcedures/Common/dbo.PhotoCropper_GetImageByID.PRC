


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PhotoCropper_GetImageByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PhotoCropper_GetImageByID]
go

create Procedure dbo.PhotoCropper_GetImageByID
(		
	@ImageID int
)	
as


/* 
	Stored procedure to get Images from Cropper tool image table.  
	Content owned by India team, please notify asaxena@opentable.com if changing.
*/

	select 
		CroppedImage 
	from
		PhotoCropperImages
	where
		ImageID = @ImageID
go

grant execute on [PhotoCropper_GetImageByID] TO ExecuteOnlyRole

go




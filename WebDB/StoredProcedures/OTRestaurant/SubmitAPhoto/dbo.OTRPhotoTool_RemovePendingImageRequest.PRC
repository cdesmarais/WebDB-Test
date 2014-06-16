

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTRPhotoTool_RemovePendingImageRequest]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTRPhotoTool_RemovePendingImageRequest]
go

create procedure [dbo].[OTRPhotoTool_RemovePendingImageRequest]
(
	@RID int
)
as
begin
	/*
		This procedure removes the pending image request from the OTRSubmittedImages table.
		Content owned by India team. Please notify asaxena@opentable.com, if changing.
	*/

	delete from
		OTRSubmittedImages
	where
		RID = @RID
end

go

grant execute on [OTRPhotoTool_RemovePendingImageRequest] to ExecuteOnlyRole

go


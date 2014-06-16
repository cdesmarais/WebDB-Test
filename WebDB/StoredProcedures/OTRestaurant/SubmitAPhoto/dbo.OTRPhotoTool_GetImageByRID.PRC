

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTRPhotoTool_GetImageByRID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTRPhotoTool_GetImageByRID]
go

create procedure [dbo].[OTRPhotoTool_GetImageByRID]
(
	@RID int
)
as
begin
	/*
		This procedure returns the image information from the OTRSubmittedImages table for a restaurant.
		Content owned by India team. Please notify asaxena@opentable.com, if changing.
	*/

	select 
		osi.OTRSubmittedImagesID
		,osi.ImageFileName
		,osi.ImageBytes
		,osi.SubmittedBy
		,osi.SubmittedDTUTC
		,d.PrimaryLanguageID
		,osi.ImageID
	from
		OTRSubmittedImages osi		
	inner join
		Domain d
		on osi.SourceDomainID = d.DomainID
	where
		osi.RID = @RID

end

go

grant execute on [OTRPhotoTool_GetImageByRID] to ExecuteOnlyRole

go


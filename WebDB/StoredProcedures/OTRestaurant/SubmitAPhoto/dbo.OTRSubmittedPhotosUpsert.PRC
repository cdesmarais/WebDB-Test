

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTRSubmittedPhotosUpsert]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTRSubmittedPhotosUpsert]
GO
create procedure [dbo].[OTRSubmittedPhotosUpsert]
(
	@RID int
	,@ImgFileName varchar(100)
	,@Image Image
	,@SubmittedBy varchar(100)
	,@SourceDomainID int
	,@ImageID varchar(50)
)
as
begin

	/*
		This procedure adds the restaurant''''s image from OTRestaurant Submit a Photo feature to the pending queue.
		Content owned by India team. Please notify asaxena@opentable.com, if changing.
	*/
	SET @SourceDomainID = (SELECT DomainID from Restaurant where RID = @RID)
	
	update
		OTRSubmittedImages
	set
		ImageFileName = @ImgFileName
		,ImageBytes = @Image
		,SubmittedBy = @SubmittedBy
		,SubmittedDTUTC = getutcdate()
		,SourceDomainID = @SourceDomainID
		,ImageID = @ImageID
	where
		RID = @RID
	
	/* If no rows were updated then it means that the a prev record does not exist so insert into the table */
	if (@@rowcount = 0)
		begin
			insert into
				OTRSubmittedImages
				(
					RID
					,ImageFileName
					,ImageBytes
					,SubmittedBy
					,SubmittedDTUTC
					,SourceDomainID
					,ImageID
				)
				values
				(
					@RID
					,@ImgFileName	
					,@Image
					,@SubmittedBy
					,getutcdate()
					,@SourceDomainID
					,@ImageID
				)
		end
end
go
grant execute on [OTRSubmittedPhotosUpsert] to ExecuteOnlyRole
go


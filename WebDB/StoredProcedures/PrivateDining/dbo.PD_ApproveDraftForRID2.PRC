


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PD_ApproveDraftForRID2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PD_ApproveDraftForRID2]
go

create procedure dbo.PD_ApproveDraftForRID2
(
	@RID int
	,@ApprovedBy varchar(100)
	,@UpdatedValues text
	,@LanguageId int
	,@IsPPD bit
	,@PublishPPDChangeStatus int
)
 
as  

/* 
	Private Dining : This stored procedure does the post approval DB updates.
	Content owned by India team, please notify asaxena@opentable.com if changing.
*/
declare @DBError int
declare @CurrUTCDate datetime
declare @PDDraftId int


/* Set transaction isolation level to read uncommited */
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


-- Get current date (UTC)
set @CurrUTCDate = getutcdate()

begin transaction


select distinct
	@PDDraftId = RequestId 
from 
	PrivateDiningDraftVW 
where 
	RID = @RID
	and ISDraftSubmitted = 1 
	
/* if draft does not exists for that RID then delete the images else do no delete the images*/	
if not exists (select 1 from PrivateDiningInfoDraft  where
RID = @RID and IsDraftSubmitted = 0)
begin
	/* Delete images for the restaurant from database after approval */
	delete from PhotoCropperImages 
	where 
		ImageID in
		(select PrivateDiningThumbnailImageID 
			from PrivateDiningInfoDraft
			where PrivateDiningDraftId = @PDDraftId)

	set @DBError = @@error
	if @DBError <> 0
		goto general_error

	delete from PhotoCropperImages 
	where 
		ImageID in (select PrivateRoomImageId from RestaurantRoomsDraft
		where 
			PrivateDiningDraftId = @PDDraftId)

	set @DBError = @@error
	if @DBError <> 0
		goto general_error
end


delete from RestaurantRoomsDraft 
where 
	PrivateDiningDraftId = @PDDraftId
	
set @DBError = @@error
if @DBError <> 0
	goto general_error

delete from PrivateDiningInfoDraft 
where 
	PrivateDiningDraftId = @PDDraftId
	
set @DBError = @@error
if @DBError <> 0
	goto general_error

/* Update Log if changes are made by approver during Approve */
if(@UpdatedValues is not null)
begin
	exec PD_InsertChangeLog2 @RID,@ApprovedBy,@UpdatedValues,@ApprovedBy,0,1,@PDDraftId,@LanguageId,@IsPPD,@PublishPPDChangeStatus /* SubmittedFromOTR = 0 and IsSubmitted =1 */
	set @DBError = @@error
	if @DBError <> 0
		goto general_error
end

/* Make last draft request as approved for RequestId. */
Update 
	PrivateDiningUpdateLog
set 
	ApprovedDTUTC = @CurrUTCDate
	,ApprovedBy = @ApprovedBy
	,Action ='Approved'
where
	PDLogId = (select 
					max(PDLogId) 
				from 
					PrivateDiningUpdateLog 
				where 
					RequestId = @PDDraftId
					and SubmittedFromOTR = 1 
				group by RequestId
			)
	
set @DBError = @@error
if @DBError <> 0
	goto general_error




commit transaction
/* Draft is approved Successfully, so return Request Id...  */
select @PDDraftId

Return(0)

general_error:
	rollback transaction	
	Return(-1)
go
	

GRANT EXECUTE ON [PD_ApproveDraftForRID2] TO ExecuteOnlyRole
go



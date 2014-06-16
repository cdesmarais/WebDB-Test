


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PD_ApproveDraftForRID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PD_ApproveDraftForRID]
go

create procedure dbo.PD_ApproveDraftForRID
(
	@RID int
	,@ApprovedBy varchar(100)
	,@UpdatedValues text
	,@LanguageId int
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
	exec PD_InsertChangeLog @RID,@CurrUTCDate,@ApprovedBy,@UpdatedValues,@CurrUTCDate,@ApprovedBy,0,1,@PDDraftId,@LanguageId /* SubmittedFromOTR = 0 and IsSubmitted =1 */
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

/* Delete  Draft images for the restaurant from database after approval */

delete from 
	PhotoCropperImages
where 
	RID = @RID
	
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
	

GRANT EXECUTE ON [PD_ApproveDraftForRID] TO ExecuteOnlyRole
go



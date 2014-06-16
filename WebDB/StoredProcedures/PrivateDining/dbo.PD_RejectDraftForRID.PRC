


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PD_RejectDraftForRID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PD_RejectDraftForRID]
go

create procedure dbo.PD_RejectDraftForRID
(
	 @RID int
	,@RejectedBy nvarchar(500)
)
 
as  

	/* 
		Private Dining : This stored procedure Reject draft so delete entries from PD Draft tables
		Content owned by India team, please notify asaxena@opentable.com if changing.
	*/
	declare @DBError int
	declare @CurrUTCDate datetime
	declare @PDDraftId int


	/* Set transaction isolation level to read uncommited */
	set transaction isolation level read uncommitted


	-- Get current date (UTC)
	set @CurrUTCDate = getutcdate()

	begin transaction

	/*Getting the Draft ID*/
	select distinct
		@PDDraftId = RequestId 
	from 
		PrivateDiningDraftVW 
	where 
		RID = @RID
		and ISDraftSubmitted = 1 
		

	/*Deleting Room information for Draft*/
	delete from RestaurantRoomsDraft 
	where 
		PrivateDiningDraftId = @PDDraftId
		
	set @DBError = @@error
	if @DBError <> 0
		goto general_error

	/*Deleting request information for Draft*/
	delete from PrivateDiningInfoDraft 
	where 
		PrivateDiningDraftId = @PDDraftId
		
	set @DBError = @@error
	if @DBError <> 0
		goto general_error

	/*Update log table*/
	Update 
		PrivateDiningUpdateLog
	set 
		RejectedDTUTC = @CurrUTCDate
		,RejectedBy = @RejectedBy
		,Action = 'Rejected'
		where
		PDLogId = (
				select 
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
	
	select 0
	return

	general_error:
		rollback transaction	
		select -1 
		return
go
	

grant execute on [PD_RejectDraftForRID] to ExecuteOnlyRole
go



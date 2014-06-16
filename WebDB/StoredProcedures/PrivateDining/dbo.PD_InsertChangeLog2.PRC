

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PD_InsertChangeLog2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PD_InsertChangeLog2]
go

create procedure dbo.PD_InsertChangeLog2
(
	@RID int	
	,@UpdatedBy varchar(100)
	,@UpdatedValues text
	,@ApprovedBy varchar(100)
	,@SubmittedFromOTR bit
	,@IsSubmitted bit
	,@RequestId int
	,@LanguageId int
	,@IsPPD bit
	,@PublishPPDChangeStatus int --( 1 check , 0 uncheck , -1 No Change)
)
 
as  

/* 
	Private Dining : Stored procedure to insert data in Private dining change log table and get ChangeLogId.
	Content owned by India team, please notify asaxena@opentable.com if changing.
*/

	declare @CurrUTCDate datetime
	declare @ApprovedDate datetime
	
	-- Get Current UTC date
	set @CurrUTCDate = GETUTCDATE()
	
	/* If Change is submitted from CHARM, set Approved date as Update date */
	if(@SubmittedFromOTR = 0) 
	begin
		set @ApprovedDate = @CurrUTCDate 
	end 
	
	-- ( -1 ) will be treated as  No Change (Null) in PublishPPDChangeStatus
	if @PublishPPDChangeStatus = -1 
	begin
		set @PublishPPDChangeStatus = null
	end
	
	-- Update the Change Log
	insert into [PrivateDiningUpdateLog]
	(     
		[RID]
		,[UpdateLogDTUTC]
		,[UpdatedBy]
		,[UpdatedValues]
		,[ApprovedDTUTC]
		,[ApprovedBy]
		,[SubmittedFromOTR]
		,[IsSubmitted]
		,[RequestId]
		,[LanguageId]
		,[IsPPD]
		,[PublishPPDChangeStatus]        
	)
    values
	(
		@RID
		,@CurrUTCDate
		,@UpdatedBy
		,@UpdatedValues
		,@ApprovedDate 
		,@ApprovedBy
		,@SubmittedFromOTR
		,@IsSubmitted
		,@RequestId
		,@LanguageId
		,@IsPPD
		,@PublishPPDChangeStatus
	)	 	
	
go
	
GRANT EXECUTE ON [PD_InsertChangeLog2] TO ExecuteOnlyRole
go





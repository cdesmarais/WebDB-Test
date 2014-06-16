

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PD_InsertNGetChangeLogId]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PD_InsertNGetChangeLogId]
go

create procedure dbo.PD_InsertNGetChangeLogId
(
	@RID int	
	,@UpdatedBy varchar(100)
	,@UpdatedValues text
	,@ApprovedBy varchar(100)
	,@SubmittedFromOTR bit
	,@IsSubmitted bit
	,@RequestId int
	,@LanguageId int
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
	)
	 
	
	-- Get PD Log id.
	select SCOPE_IDENTITY()
	
go
	
GRANT EXECUTE ON [PD_InsertNGetChangeLogId] TO ExecuteOnlyRole
go





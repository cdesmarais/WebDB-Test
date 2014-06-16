

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PD_InsertChangeLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PD_InsertChangeLog]
go

create procedure dbo.PD_InsertChangeLog
(
	@RID int	
	,@UpdateLogDTUTC datetime
	,@UpdatedBy varchar(100)
	,@UpdatedValues text
	,@ApprovedDTUTC datetime
	,@ApprovedBy varchar(100)
	,@SubmittedFromOTR bit
	,@IsSubmitted bit
	,@RequestId int
	,@LanguageId int
)
 
as  

/* 
	Private Dining : Stored procedure to insert data in Private dining change log table.
	Content owned by India team, please notify asaxena@opentable.com if changing.
*/

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
		,@UpdateLogDTUTC
		,@UpdatedBy
		,@UpdatedValues
		,@ApprovedDTUTC 
		,@ApprovedBy
		,@SubmittedFromOTR
		,@IsSubmitted
		,@RequestId
		,@LanguageId
	)
go
	


GRANT EXECUTE ON [PD_InsertChangeLog] TO ExecuteOnlyRole
go





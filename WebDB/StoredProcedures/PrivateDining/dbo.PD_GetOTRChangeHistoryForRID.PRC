

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PD_GetOTRChangeHistoryForRID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PD_GetOTRChangeHistoryForRID]
go

create procedure dbo.PD_GetOTRChangeHistoryForRID
(
	@RID int
	,@ShowAllRecord bit
)
 
as  

-- DECLARE variables to hold the total records to View all changes for history
 declare @totalrecords int
 set @totalrecords = (Select COUNT(*) from PrivateDiningUpdateLog where  
						RID = @RID   
					and 
						SubmittedFromOTR = 1 )

/* 
	Private Dining : Stored procedure to get Private Dining Change history for OTR.
	Content owned by India team, please notify asaxena@opentable.com if changing.
*/

if (@showAllrecord = 0)
	begin
		select 
			top 20
			PDLogId as RestPDUpdateID
			,RID
			,dbo.fConvertFromUTC(UpdateLogDTUTC,4)as UpdateLogDatePST
			,UpdatedBy 
			,UpdatedValues as UpdatedValuesXML
			,IsSubmitted
			,@totalrecords as totalrecords
		from
			PrivateDiningUpdateLog 
		where
			RID = @RID 
			and SubmittedFromOTR = 1
		order by
			UpdateLogDatePST desc
	end
else
	begin
		select 
				PDLogId as RestPDUpdateID
				,RID
				,dbo.fConvertFromUTC(UpdateLogDTUTC,4)as UpdateLogDatePST
				,UpdatedBy 
				,UpdatedValues as UpdatedValuesXML
				,IsSubmitted
				,@totalrecords as totalrecords
			from
				PrivateDiningUpdateLog 
			where
				RID = @RID 
				and SubmittedFromOTR = 1
			order by
				UpdateLogDatePST desc
	end

go

GRANT EXECUTE ON [PD_GetOTRChangeHistoryForRID] TO ExecuteOnlyRole
go





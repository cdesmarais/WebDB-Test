

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PD_UnlockForEdit]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PD_UnlockForEdit]
go

create procedure dbo.PD_UnlockForEdit
(
	@RID int
	,@UnlockedBy nvarchar(100)
)
 
as  

/* 
	Private Dining : Stored procedure to Unlock offer for edit which was locked due to 24 hr lock.
	Content owned by India team, please notify asaxena@opentable.com if changing.
*/

	-- Update Lock override date
	update 
		PrivateDiningUpdateLog 
	set
		LockOverrideDTUTC = getutcdate()
		,UnlockedBy = @UnlockedBy
	where
		PDLogId = (select 
					max(PDLogID) 
				from 
					PrivateDiningUpdateLog 
				where 
					RID= @RID 
					and IsSubmitted = 1
				 	and SubmittedFromOTR = 1
				)

go
	

GRANT EXECUTE ON [PD_UnlockForEdit] TO ExecuteOnlyRole
go



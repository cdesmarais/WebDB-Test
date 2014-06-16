


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PD_GetEditLockInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PD_GetEditLockInfo]
go

create procedure dbo.PD_GetEditLockInfo
(
	@RID int	
)
 
as  

/* 
	Private Dining : Stored procedure to get the private dining lock information
	Content owned by India team, please notify asaxena@opentable.com if changing.
*/

	declare @LockOverrideDTUTC datetime
	declare @UpdateLogDTUTC datetime
	declare @UnlockedBy nvarchar(500)
	declare @IsAutoLock bit
	declare @LastUnlockDatePST datetime
	declare @LastUnlockedBy nvarchar(500)

	-- Lock Status Information
		-- 0 is lock
		-- 1 is Unlock normal
		-- 2 is unlock override
		-- 3 is No record found
	
	/* Read the last update log for restaurant in local variables */	
	select top(1) 
		@LockOverrideDTUTC = LockOverrideDTUTC
		,@UpdateLogDTUTC = UpdateLogDTUTC
		,@UnlockedBy = UnlockedBy
		,@IsAutoLock = (case when (getutcdate() < DATEADD(hh,24,UpdateLogDTUTC)) then 1
							else 0 end  )		
	from 
		PrivateDiningUpdateLog
	where
		RID = @RID
		and IsSubmitted =1
		and SubmittedFromOTR = 1
	order by 
		PDLogId desc,UpdateLogDTUTC desc
	
	
	/* If PD info is not locked, get last unlock info  */	
	if(@IsAutoLock = 0 or @LockOverrideDTUTC is NULL)
	begin
		select top(1)
			 @LastUnlockDatePST = dbo.fConvertFromUTC(LockOverrideDTUTC,4)
			,@LastUnlockedBy = UnlockedBy 
		from
			PrivateDiningUpdateLog
		where 
			RID = @RID			
			and not LockOverrideDTUTC is NULL 
		ORDER BY 
			LockOverrideDTUTC DESC 
	end
	
		
	if @UpdateLogDTUTC is NULL
		begin
			select 3 as LockStatus
		end
	else
		begin
			if @IsAutoLock = 0
				begin 
					select 
						@LastUnlockDatePST as UnlockDatePST
						,@LastUnlockedBy 
						,@LastUnlockedBy as UnlockedBy
						,1 as LockStatus;
				end
			else
				begin
					if(@LockOverrideDTUTC is NULL)
						begin
							select
								@LastUnlockDatePST as UnlockDatePST 
								,@LastUnlockedBy as UnlockedBy
								,@UpdateLogDTUTC as UpdateLogDTUTC
								,0 as LockStatus
						end
					else
						begin
							select 
								dbo.fConvertFromUTC(@LockOverrideDTUTC,4) as UnlockDatePST
								,@UnlockedBy as UnlockedBy
								,2 as LockStatus					
						end
				end
		end
go
	

GRANT EXECUTE ON [PD_GetEditLockInfo] TO ExecuteOnlyRole
go



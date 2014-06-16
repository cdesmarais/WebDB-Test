

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateERBLockStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateERBLockStatus]
GO

create procedure dbo.UpdateERBLockStatus
(
	@RestaurantID int,
	@IsLocked int,
	@ROMSUser nvarchar(100)  
)
as 

/*********************************************************
Purpose: To Lock and UnLock Restaurant in charm from ROMS
*********************************************************/

Begin Transaction
declare @RestState int
declare @LastRestState int  
set @LastRestState = -1  

	-- select RestStateID for "Initiating Uninstall"
	select 
		@RestState = RestStateID 
	from 
		Restaurantstate
	where 
		RState = 'Initiating Uninstall'
  
	-- Lock Restaurant in charm from ROMS.
	if (@IsLocked = 1)
		begin
			-- Update Restaurant status to "initiating uninstall".
			update 
				Restaurant
			set 
				RestStateID = @RestState
			where 
				RID = @RestaurantID

			-- Lock Restaurant
			update 
				ERBRestaurant
			set 
				ERBLockFromROMS = @IsLocked
			where 
				RID = @RestaurantID
			
			-- Log the status change in RestStatusTrackLog table.
			exec Admin_AuditRestStatusChg @RestaurantID,@ROMSUser,@RestState
		end
	
	-- Unlock Restaurant in charm from ROMS.
	else if (@IsLocked = 0)
		begin
			declare @LockStatus int
			-- select the ERBLockFromROMS value.
			select 
				@LockStatus = ERBLockFromROMS
			from
				ERBRestaurant
			where
				RID = @RestaurantID
		
			-- check the ERBLockFromROMS status..
			if (@LockStatus = 1)
			begin
				-- select the status, status prior to the "initiating uninstall".
				select 
					top 1 @LastRestState=newstatus 
				from 
					RestStatusTrackLog 
				where 
					rid=@RestaurantID 
					and newstatus <> @RestState 
				order by 
					statuschangedatets desc  

				-- update Restaurant status, the status prior to the "initiating uninstall"
				update 
					Restaurant
				set 
					RestStateID = @LastRestState
				where 
					RID = @RestaurantID

				-- UnLock Restaurant
				update 
					ERBRestaurant
				set 
					ERBLockFromROMS = @IsLocked
				where 
					RID = @RestaurantID
				
				-- Log the status change in RestStatusTrackLog table.
				exec Admin_AuditRestStatusChg @RestaurantID,@ROMSUser,@LastRestState
			end
		end

Commit Transaction
Return(0)

error:
Rollback Transaction
GO

GRANT EXECUTE ON [UpdateERBLockStatus] TO ExecuteOnlyRole
GO


  
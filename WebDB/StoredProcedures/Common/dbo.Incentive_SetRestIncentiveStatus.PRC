
  
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Incentive_SetRestIncentiveStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Incentive_SetRestIncentiveStatus]
GO

create procedure [dbo].[Incentive_SetRestIncentiveStatus]  
(  
	@RID int,  
	@RestaurantStateID int  
)  

as  
  
begin transaction  
  
		declare @Status nvarchar(255),   
				@IncHistID int,   
				@StartDate datetime,  
				@EndDate datetime,   
				@IncStatusID int,  
				@ContractSignedBy nvarchar(255),
				@ContractSoldBy nvarchar(255),
                @ContractEffectiveDate datetime 
	    
		select	@IncStatusID = IncStatusID, 
				@StartDate = StartDate, @EndDate = EndDate,   
				@ContractSignedBy = ContractSignedBy,
				@ContractSoldBy = ContractSoldBy,
                @ContractEffectiveDate = ContractEffectiveDate
		
		from IncentiveRestaurantStatus   
	
		where RID = @RID  
		AND Active = 1  

		--When restaurant state is Inactive
		set @IncStatusID = coalesce(@IncStatusID, 0)
		if(@RestaurantStateID = 4 and @IncStatusID = 1)
		begin
            -- Create history record. Here pass DraftsubmitDate as null.
            --When draftSubmitdate parameter is null then the stored procedure Incentive_InsertIncentiveHistory 
            --internally set this date as the current date.

			exec Incentive_InsertIncentiveHistory @RID, 'POP Cancelled', @ContractSignedBy, null, null, null, null, 
					'Automatic', @ContractSoldBy, @IncHistID OUTPUT,null,@ContractEffectiveDate

			if @@error <> 0
				goto error
			
			-- Insert the record. set Restaurant's dip status as 'Not a DIP Customer (id = 2)'
			Exec Incentive_UpdateRestaurantIncentiveStatus1 @RID, @IncHistID, 2, @ContractSignedBy,
					@StartDate, @EndDate, @ContractSoldBy, @ContractEffectiveDate

			if @@error <> 0
				goto error
		end
  
		commit transaction  
		return(0)  
  
	error:  
		rollback transaction  
		return(0)  
  
GO

GRANT EXECUTE ON [Incentive_SetRestIncentiveStatus] TO ExecuteOnlyRole

GO




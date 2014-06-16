
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpsertUmamiGoLiveActivationQueue]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpsertUmamiGoLiveActivationQueue]
go

create procedure [dbo].[UpsertUmamiGoLiveActivationQueue]
(
    @RID int
    ,@GoLiveType varchar(10) = null
    ,@GoLiveDtUTC datetime = null
    ,@RestContactEmail nvarchar(100) = null
    ,@ProcessedDtUTC datetime = null
)
as
	
	declare @RIDFromRest int
	declare @RIDFromQue int
	declare @RecordProcessedDtUTC datetime
	declare @RestaurantStatus int
	

	--Setting default values
	set @RIDFromRest = -1
	set @RIDFromQue = -1
	set @RecordProcessedDtUTC = null	
	
	--Getting required data from Restaurant and UmamiGoLiveActivationQueue table for validation purpose.
	select 
		 @RIDFromRest = rest.RID
		,@RIDFromQue = act_queue.RID
		,@RecordProcessedDtUTC = act_queue.ProcessedDtUTC
	from
		Restaurant rest
		left outer join UmamiGoLiveActivationQueue act_queue		
		on act_queue.RID = rest.RID
	where
		rest.RID = @RID
		

	--Checking whether RID exist or not in Restaurant table
	if @RIDFromRest = -1
	begin
		select -1
		return
	end
	
	--Checking whether record already exist in queue, If it does then update otherwise insert
    if @RIDFromQue != -1
    begin
		
		--Checking whether record is already process or not.
		if @RecordProcessedDtUTC is not null
		begin
			select -2
			return
		end
		
		update
			UmamiGoLiveActivationQueue
		set
			GoLiveType = ISNULL(@GoLiveType, GoLiveType)
			,GoLiveDtUTC = @GoLiveDtUTC
			,RestContactEmail = ISNULL(@RestContactEmail, RestContactEmail)
			,ProcessedDtUTC = ISNULL(@ProcessedDtUTC, ProcessedDtUTC)
		where
			RID = @RID
	end
	else	
	begin
		-- insert the record.
		insert into UmamiGoLiveActivationQueue
		(
			RID
			,GoLiveType
			,GoLiveDtUTC
			,RestContactEmail
		)
		values
		(
			@RID
			,@GoLiveType
			,@GoLiveDtUTC
			,@RestContactEmail
		)
    end
    
    --Setting Default value to @RestaurantStatus
    set @RestaurantStatus = null
    
    -- If @GoLiveType is Future or Delyed then RestaurantStatus = Client Grace Period
    if @GoLiveType = 'FUTURE'  or @GoLiveType = 'DELAYED'
    begin
		set @RestaurantStatus = 10 -- Client Grace Period
		
		-- If FUTURE record is processed then we are going set Restaurant Status = Active
		if @ProcessedDtUTC is not null and @GoLiveType = 'FUTURE'
		begin
			set @RestaurantStatus = 1 -- Active
		end 
    end
    
    --When GoLiveType = IMMEDIATE restaurant is going to be Active.
    if @GoLiveType = 'IMMEDIATE' 
    begin
		set @RestaurantStatus = 1 -- Active
    end
    
    --If RestaurantStatus is need to be updated.	
	if @RestaurantStatus is not null 
	begin
		-- Update the restaurant status , If @RestaurantStatus is null then not changining the status.
		update 
			Restaurant
		set
			RestStateID = @RestaurantStatus
		where
			RID = @RID
		
		--Updating the Status Change Log.	
		exec Admin_AuditRestStatusChg 
								 @RID
								,'System'
								,@RestaurantStatus
	end
		
	
	
	--Returning Success	
	select 1
go

grant execute on [UpsertUmamiGoLiveActivationQueue] to ExecuteOnlyRole

go


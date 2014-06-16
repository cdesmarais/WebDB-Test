

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PD_SubmitFreeDraftOrPendingReq]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PD_SubmitFreeDraftOrPendingReq]
GO 
              
                        
create procedure dbo.PD_SubmitFreeDraftOrPendingReq                         
(                        
	@RID int                         
	,@PrivatePartyContact nvarchar(50)                        
	,@PrivatePartyEmail nvarchar(510)                        
	,@LargestCapacity int                        
	,@PrivatePartyPhone nvarchar(50)                        
	,@PrivatePartyShortDescription nvarchar(1000)                        
	,@PDChangeMask int                         
	,@SubmittedBy nvarchar(500)                        
	,@LanguageId int                        
	,@PDIsDraftSubmitted bit                     
	,@UpdatedValues text                     
)                        
as 
Begin                     
/*                         
 Private Dining : Stored procedure to insert data in PrivateDiningInfoDraft table for 
 Pending request or draft.                          
*/                        
                         
	declare @DBError int                        
	declare @CurrUTCDate datetime                        
	declare @IsDraftExists bit                        
	declare @IsLockedForEdit int                        
	declare @PDDraftId int                        
	declare @IsNewRequest bit                   
	declare @PDIsPendRequest bit
	declare @IsNewPremiumRequest bit
	declare @IsFirstSubmission bit

	declare @IsContactNmAdded int 
	declare @IsShortDescAdded int
	declare @IsPrivatPartContactAdded int	
	
	set @IsNewPremiumRequest = 0     
	set @PDIsPendRequest = 0             
	set @IsFirstSubmission = 0
	                      
	 /* Set transaction isolation level to read uncommited */                        
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED                        
	                         
	 -- Get Current UTC date                        
	set @CurrUTCDate = GETUTCDATE() 
	                     
	-- check if live free data exists                   
	select 
		@IsContactNmAdded = len(ISNULL(PrivatePartyContact,''))
		,@IsPrivatPartContactAdded = len(ISNULL(PrivatePartyPhone,''))
	from
		restaurantvw
	where
		RID = @RID
		
	SELECT top 1 
			@IsShortDescAdded = len(ISNULL([Message],''))
	FROM
		[RestaurantCustomMessageVW] 
	WHERE 
		rid = @RID
		and [MessageTypeID] = 54  
		                         
	if(@IsContactNmAdded < 1 and @IsPrivatPartContactAdded < 1 and @IsShortDescAdded < 1)
			set @IsFirstSubmission = 1
			                                                  
	-- check if draft already exists ...      
	select top 1 
		@IsDraftExists = 1
		,@PDDraftId = RequestID
		,@IsContactNmAdded = len(ISNULL(PrivatePartyContact,''))
		,@IsPrivatPartContactAdded = len(ISNULL(PrivatePartyPhone,''))
		,@IsShortDescAdded  = len(ISNULL(PartyShortDesc,''))
	from
		PrivateDiningDraftVW
	where
		RID = @RID 
		and ISDraftSubmitted = @PDIsDraftSubmitted    
            
    select isnull(@IsDraftExists,0)   
                    
	begin transaction                        
	                        
	 -- If draft already exists, then delete it...                        
	 if @IsDraftExists = 1                      
	 begin  
		-- set to false since pending request is already submitted
		if(@IsContactNmAdded>0 and @IsPrivatPartContactAdded > 0 and @IsShortDescAdded > 0 and @PDIsDraftSubmitted = 1) 		            	
			set @IsFirstSubmission = 0  
			           
		update                        
			PrivateDiningInfoDraft                        
		set                        
		   [PrivatePartyContact] = @PrivatePartyContact                        
		   ,[LargestCapacity] = @LargestCapacity                           
		   ,[PrivatePartyEmail] = @PrivatePartyEmail                        
		   ,[PrivatePartyPhone] = @PrivatePartyPhone                         
		   ,[PrivatePartyShortDescription] = @PrivatePartyShortDescription                          
		   ,[PDChangeMask] = @PDChangeMask                        
		   ,[ModifiedDTUTC] = @CurrUTCDate                        
		   ,[SubmittedBy] = @SubmittedBy                        
		   ,[LanguageId] = @LanguageId                        
		   ,[IsNewPremiumRequest]   = @IsNewPremiumRequest                        
		   ,[ISDraftSubmitted] = @PDIsDraftSubmitted                    
		where                        
			PrivateDiningDraftID = @PDDraftId                        
		                
		set @DBError = @@error                        
		if @DBError <> 0                        
		goto general_error   

	                   
	 end                        
	 else                        
	 begin                 
		 -- Update the Private Dining info in draft table                        
		 insert into [PrivateDiningInfoDraft]                        
		  (                        
			 [RID]                        
			,[PrivatePartyContact]                        
			,[PrivatePartyEmail]                           
			,[LargestCapacity]                        
			,[PrivatePartyPhone]                        
			,[PrivatePartyShortDescription]                        
			,[PDChangeMask]                        
			,[ModifiedDTUTC]                        
			,[SubmittedBy]                        
			,[LanguageId]                        
			,[IsNewPremiumRequest]                           
			,[ISDraftSubmitted]                    
		   )                        
		  values                        
		  (                        
			@RID                        
			,@PrivatePartyContact                        
			,@PrivatePartyEmail                        
			,@LargestCapacity                        
			,@PrivatePartyPhone                        
			,@PrivatePartyShortDescription                        
			,@PDChangeMask                        
			,@CurrUTCDate                        
			,@SubmittedBy                        
			,@LanguageId                        
			,@IsNewPremiumRequest                     
			,@PDIsDraftSubmitted                       
		  )                 
		
		set @PDDraftId = SCOPE_IDENTITY()                        
	                        
		set @DBError = @@error                        
		if @DBError <> 0                        
			goto general_error                        
	 end                        
	                     
	 if @PDIsDraftSubmitted = 1                         
	 begin                    
		delete from PrivateDiningInfoDraft where RID = @RID and ISDraftSubmitted = 0 
		--set this flag as 1 for Pending request to insert in PrivateDiingUpdateLog table for ISSubmitted column.
		set @PDIsPendRequest = 1                
	  
	 end                   

	--Insert into  PrivateDiningUpdateLog this table to log changes               
	exec PD_InsertChangeLog1 @RID,@SubmittedBy,@UpdatedValues,null,1,@PDIsPendRequest,@PDDraftId,@LanguageId,0             
	                  
	set @DBError = @@error                        
	if @DBError <> 0                        
		goto general_error                         
	                    
	-- since this procedure is always called from OTR. it will always have deactivate free list flag as flag.
	-- this will change while implementation deactivate free listing through OTR  
	exec PD_UpdatePDTrackingData @RID,0,0,@PDIsDraftSubmitted,0,@IsFirstSubmission  
      set @DBError = @@error                        
	if @DBError <> 0                        
		goto general_error 
           
	commit transaction                        
		Return(0)                        
	                    
	general_error:                        
		rollback transaction                         
		Return(-1) 
End
GO

GRANT EXECUTE ON [PD_SubmitFreeDraftOrPendingReq] TO ExecuteOnlyRole

GO



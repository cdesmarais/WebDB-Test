


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PD_SubmitDraftPremiumOrPendReq]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PD_SubmitDraftPremiumOrPendReq]
GO 
              
create procedure dbo.PD_SubmitDraftPremiumOrPendReq                  
(                  
	 @RID int 	
	 
	,@RoomName1 nvarchar(100)                    
	,@RoomDesc1 nvarchar(500)                    
	,@SeatedSize1 int                    
	,@StandingSize1 int                    
	,@RoomImageID1 int                   
	,@RoomImageName1 nvarchar(100)                   
	,@ListingOrder1 int                    
	,@RoomChangeMask1 int                  
	,@Active1 bit                    
                     
	,@RoomName2 nvarchar(100)                    
	,@RoomDesc2 nvarchar(500)                    
	,@SeatedSize2 int                    
	,@StandingSize2 int                    
	,@RoomImageID2 int                   
	,@RoomImageName2 nvarchar(100)                    
	,@ListingOrder2 int                    
	,@RoomChangeMask2 int                  
	,@Active2 bit                    
                     
	,@RoomName3 nvarchar(100)                    
	,@RoomDesc3 nvarchar(500)                    
	,@SeatedSize3 int                    
	,@StandingSize3 int                    
	,@RoomImageID3 int                    
	,@RoomImageName3 nvarchar(100)                   
	,@ListingOrder3 int                    
	,@RoomChangeMask3 int                  
	,@Active3 bit                    
                     
	,@RoomName4 nvarchar(100)                    
	,@RoomDesc4 nvarchar(500)                    
	,@SeatedSize4 int                    
	,@StandingSize4 int                    
	,@RoomImageID4 int                   
	,@RoomImageName4 nvarchar(100)                    
	,@ListingOrder4 int                    
	,@RoomChangeMask4 int                  
	,@Active4 bit                    
                     
	,@RoomName5 nvarchar(100)                    
	,@RoomDesc5 nvarchar(500)                    
	,@SeatedSize5 int                    
	,@StandingSize5 int                    
	,@RoomImageID5 int                    
	,@RoomImageName5 nvarchar(100)                     
	,@ListingOrder5 int                    
	,@RoomChangeMask5 int                   
	,@Active5 bit                    
                  
	,@PrivatePartyContact nvarchar(50)                  
	,@LargestCapacity int                  
	,@PrivateDiningMenuURL nvarchar(500)                  
	,@PrivatePartyEmail nvarchar(510)                  
	,@PrivatePartyPhone nvarchar(50)                  
	,@PrivateDiningThumbnailImageID int                  
	,@PrivateDiningThumbnailImageName nvarchar(100)                  
	,@PrivatePartyShortDescription nvarchar(1000)                  
	,@PrivatePartyLongDescription nvarchar(1000)                  
	,@PDChangeMask int                  
	,@SubmittedBy nvarchar(500)                  
	,@PremiumEnabled bit                  
	,@LanguageId int                  
	,@PDIsDraftSubmitted bit                     
	,@UpdatedValues text             
)                  
as  
Begin              
	/*                   
	Private Dining : Stored procedure to submit draft/pending request Private Dining information. 
	*/                  
	              
	declare @DBError int                  
	declare @CurrUTCDate datetime                  
	declare @IsDraftExists int                  
	declare @IsLockedForEdit int                  
	declare @PDDraftId int                  
	declare @bIsNewPremiumRequest bit 
	declare @PDIsPendRequest bit   
	declare @IsFirstSubmission bit
	declare @IsPendRequestAlreadySubmitted bit
	set @bIsNewPremiumRequest = 0   
	set @PDIsPendRequest = 0
	set @IsFirstSubmission = 0
	
	-- check if live premium data already exists  
	if not exists (select 1 from RestaurantRooms where RID =  @RID 
	and LEN(ISNULL(RoomName,'')) > 0 and LEN(ISNULL(RoomDescription,''))> 0)
		set @IsFirstSubmission = 1
	               
	/* Set transaction isolation level to read uncommited */                  
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED                  
	               
	-- Get Current UTC date                  
	set @CurrUTCDate = GETUTCDATE()                  
	   
	/* Check for new request from OTR for Private Dining
	New premium request flag status = yes in following cases		
			- First Premium Submission		
			- First submission after Free To Premium Transition
	New premium request flag status = no in following cases		
			- First FREE Submission - IsNew=0
			- Update FREE Submission - IsNew=0
			- Update Premium Submission - IsNew=0
			- First submission after Premium to Free Transition - IsNew=0*/           
	
	if(@PDIsDraftSubmitted =1)                
	Begin
		select 
			@bIsNewPremiumRequest = isnull(EnableNewPremiumRequest,0)
		from
			PDTracking
		where
			RID = @RID
	end
	        
	-- check if draft already exists      
	
	select 
		@IsDraftExists = 1
		,@PDDraftId = RequestId 
		,@IsPendRequestAlreadySubmitted = PremiumEnabled
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
		if(@IsPendRequestAlreadySubmitted  = 1 and @PDIsDraftSubmitted = 1)
			set @IsFirstSubmission = 0 
		
		delete RestaurantRoomsDraft where PrivateDiningDraftID = @PDDraftId                  
		set @DBError = @@error                  
		if @DBError <> 0                  
			goto general_error                   
       
		update                  
			PrivateDiningInfoDraft                  
		set                  
			[PrivatePartyContact] = @PrivatePartyContact                  
			,[LargestCapacity] = @LargestCapacity                  
			,[PrivateDiningMenuURL] = @PrivateDiningMenuURL                  
			,[PrivatePartyEmail] = @PrivatePartyEmail                  
			,[PrivatePartyPhone] = @PrivatePartyPhone                  
			,[PrivateDiningThumbnailImageID] = @PrivateDiningThumbnailImageID                  
			,[PrivateDiningThumbnailImageName] = @PrivateDiningThumbnailImageName                  
			,[PrivatePartyShortDescription] = @PrivatePartyShortDescription                  
			,[PrivatePartyLongDescription] = @PrivatePartyLongDescription                  
			,[PDChangeMask] = @PDChangeMask                  
			,[ModifiedDTUTC] = @CurrUTCDate                  
			,[SubmittedBy] = @SubmittedBy                  
			,[LanguageId] = @LanguageId                  
			,[PremiumEnabled] = @PremiumEnabled                  
			,[IsNewPremiumRequest] = @bIsNewPremiumRequest                  
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
			,[LargestCapacity]                  
			,[PrivateDiningMenuURL]                  
			,[PrivatePartyEmail]                   
			,[PrivatePartyPhone]                  
			,[PrivateDiningThumbnailImageID]                  
			,[PrivateDiningThumbnailImageName]                  
			,[PrivatePartyShortDescription]                  
			,[PrivatePartyLongDescription]                  
			,[PDChangeMask]                  
			,[ModifiedDTUTC]                  
			,[SubmittedBy]                  
			,[LanguageId]                  
			,[PremiumEnabled]                  
			,[IsNewPremiumRequest]                
			,[ISDraftSubmitted]              
		)                  
		values                  
		 (                  
			@RID                  
			,@PrivatePartyContact                  
			,@LargestCapacity                  
			,@PrivateDiningMenuURL                  
			,@PrivatePartyEmail                  
			,@PrivatePartyPhone                  
			,@PrivateDiningThumbnailImageID                  
			,@PrivateDiningThumbnailImageName                  
			,@PrivatePartyShortDescription                  
			,@PrivatePartyLongDescription                  
			,@PDChangeMask                  
			,@CurrUTCDate                  
			,@SubmittedBy                  
			,@LanguageId                  
			,@PremiumEnabled                  
			,@bIsNewPremiumRequest               
			,@PDIsDraftSubmitted                   
		)                  
	                  
		set @PDDraftId = SCOPE_IDENTITY()      
	              
		set @DBError = @@error                  
		if @DBError <> 0                  
			goto general_error 
	end                  
	             
	-- Update the Room Information                  
	insert into RestaurantRoomsDraft Values (@PDDraftId,@RoomName1,@RoomDesc1,@RoomImageID1,@RoomImageName1,@SeatedSize1,@StandingSize1,@ListingOrder1,@Active1, @RoomChangeMask1,@LanguageId)                    
	set @DBError = @@error                  
	if @DBError <> 0                  
		goto general_error                  
	              
	insert into RestaurantRoomsDraft Values (@PDDraftId,@RoomName2,@RoomDesc2,@RoomImageID2,@RoomImageName2,@SeatedSize2,@StandingSize2,@ListingOrder2,@Active2,@RoomChangeMask2,@LanguageId)                    
	set @DBError = @@error                  
	if @DBError <> 0                  
		goto general_error                  
	              
	insert into RestaurantRoomsDraft Values (@PDDraftId,@RoomName3,@RoomDesc3, @RoomImageID3,@RoomImageName3,@SeatedSize3,@StandingSize3,@ListingOrder3,@Active3,@RoomChangeMask3,@LanguageId)                    
	set @DBError = @@error                  
	if @DBError <> 0                  
		goto general_error                  
	              
	insert into RestaurantRoomsDraft Values (@PDDraftId,@RoomName4,@RoomDesc4, @RoomImageID4,@RoomImageName4,@SeatedSize4,@StandingSize4,@ListingOrder4,@Active4,@RoomChangeMask4,@LanguageId)                    
	set @DBError = @@error                  
	if @DBError <> 0                  
		goto general_error                  
	              
	insert into RestaurantRoomsDraft Values (@PDDraftId,@RoomName5,@RoomDesc5, @RoomImageID5,@RoomImageName5,@SeatedSize5,@StandingSize5, @ListingOrder5, @Active5, @RoomChangeMask5,@LanguageId)                    
	set @DBError = @@error                  
	if @DBError <> 0                  
		goto general_error                  
      
    if @PDIsDraftSubmitted = 1                   
	begin              
		delete from RestaurantRoomsDraft 
		where PrivateDiningDraftID in
		(select PrivateDiningDraftID from PrivateDiningInfoDraft where RID= @RID and 
		ISDraftSubmitted = 0)
		              
		delete from PrivateDiningInfoDraft 
		where RID = @RID and ISDraftSubmitted = 0   
		
		set @DBError = @@error                  
		if @DBError <> 0                  
			goto general_error 

		--Set @PDIsPendRequest=1 to insert IsSubmitted =1 for if it is a pending request.
		set @PDIsPendRequest = 1           
	end               

	--Insert in PrivateDiningUpdateLog this table to log changes.
	exec PD_InsertChangeLog1 @RID,@SubmittedBy,@UpdatedValues,null,1,@PDIsPendRequest,@PDDraftId,@LanguageId,@PremiumEnabled             
	set @DBError = @@error                  
	if @DBError <> 0                  
		goto general_error  
	
	-- since this procedure is always called from OTR. it will always have deactivate free list flag as flag.
	-- this will change while implementation deactivate free listing through OTR
	exec PD_UpdatePDTrackingData @RID, @PremiumEnabled,0,@PDIsDraftSubmitted,0,@IsFirstSubmission
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

GRANT EXECUTE ON [PD_SubmitDraftPremiumOrPendReq] TO ExecuteOnlyRole

GO




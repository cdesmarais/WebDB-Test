


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PD_UpdatePDTrackingData]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PD_UpdatePDTrackingData]
go


create procedure dbo.PD_UpdatePDTrackingData 
(
	@RID int	
	,@IsPremiumSubmission bit
	,@IsCharmSubmission bit	
	,@IsDraftSubmitted bit 	
	,@IsFreeListingDeActivated bit		
	,@IsFirstSubmission bit
)
as
begin    
	/*
		For every private dining submission either from CHARM or OTR this procedure updates private 
		dining tracking fields like first submission, last submission and updates the 
		EnableNewPremiumRequest = false for first premium submission after transition.		 		
		Content owned by India team, please notify asaxena@opentable.com if changing.
	*/
	declare @PDSubmissionDTUTC datetime
	declare @FirstPPDSubmitDtUTC datetime 
	declare @FirstFreeSubmitDtUTC datetime
	declare @DraftSubmitDtUTC datetime 
	declare @SubmissionSource varchar(15)
	declare @FirstSubmissionSource varchar(15)
	declare @EnableNewPremiumRequest  bit
	declare @DeActivateFreeListingDTUTC datetime
	declare @IsPrevPPDSubmission bit
	
	set @PDSubmissionDTUTC = GETUTCDATE()
	set @SubmissionSource = 'OTRestaurant';
	set @DraftSubmitDtUTC = null
	set @FirstPPDSubmitDtUTC = null
	set @FirstFreeSubmitDtUTC = null
	set @DeActivateFreeListingDTUTC = null
	set @EnableNewPremiumRequest = 0
			
	if(@IsCharmSubmission = 1)
	begin
		set @SubmissionSource = 'CHARM'
		-- from premium submission reset the flag to 0 and for free submission flag should also be 0
		set @EnableNewPremiumRequest  = 0 
	end
	
	
	-- If free listing is deactivated for restaurant
	if(@IsFreeListingDeActivated =1)
	begin
		set @DeActivateFreeListingDTUTC = @PDSubmissionDTUTC
		set @IsPremiumSubmission = 0
		set @EnableNewPremiumRequest = 0
	end

	-- if draft is submitted
	if(@IsDraftSubmitted = 0)
	begin
		set @DraftSubmitDtUTC = @PDSubmissionDTUTC
		set @PDSubmissionDTUTC = null
	end
	
	If @IsFirstSubmission = 1 
	begin
		set @FirstSubmissionSource = @SubmissionSource
		-- check if premium data already submitted to get the first premium submission date	 		  
		if @IsPremiumSubmission = 1 
			set @FirstPPDSubmitDtUTC = @PDSubmissionDTUTC	
		else
			set @FirstFreeSubmitDtUTC = @PDSubmissionDTUTC	
	end
		
	
	-- if no data for RID in tracking then insert else update
	if not exists(select 1 from PDTracking where RID = @RID)
	begin		
		insert into PDTracking
		(	
			RID
			,IsPremium
			,FirstPPDSubmitDtUTC
			,FirstFreeSubmitDTUTC
			,DraftSubmissionDtUTC
			,LastSubmissionDtUtc
			,FreeToPremiumTransitionDTUTC
			,PremiumToFreeTransitionDTUTC
			,LastSubmissionSource
			,FirstSubmissionSource
			,EnableNewPremiumRequest
			,DeActivateFReeListingDtUTC  
		)
		values
		(
			@RID
			,null
			,@FirstPPDSubmitDtUTC
			,@FirstFreeSubmitDtUTC
			,@DraftSubmitDtUTC
			,@PDSubmissionDTUTC
			,null
			,null
			,@SubmissionSource		
			,@FirstSubmissionSource	
			,@EnableNewPremiumRequest 
			,@DeActivateFreeListingDTUTC
		)
	end	
	else
		update  
			PDTracking
		set
			-- for draft submission from OTR
			LastSubmissionDtUtc =  coalesce(@PDSubmissionDTUTC,LastSubmissionDtUtc) 
			,LastSubmissionSource = @SubmissionSource
			,DraftSubmissionDtUTC = @DraftSubmitDtUTC
			,FirstPPDSubmitDtUTC = coalesce(@FirstPPDSubmitDtUTC,FirstPPDSubmitDtUTC)
			,FirstFreeSubmitDTUTC = coalesce(@FirstFreeSubmitDtUTC,FirstFreeSubmitDTUTC)
			,FirstSubmissionSource = coalesce(@FirstSubmissionSource,FirstSubmissionSource)
			/* disable premium request. for consecutive request do not enable the flag.flag
			is enabled only while tranistion from free to premium */
			,EnableNewPremiumRequest = case when EnableNewPremiumRequest = 1 and @IsCharmSubmission = 1 and @IsPremiumSubmission = 1 then
				@EnableNewPremiumRequest else EnableNewPremiumRequest end
			,IsPremium = @IsPremiumSubmission
			,DeActivateFReeListingDtUTC = @DeActivateFreeListingDTUTC
		where
			RID = @RID
		      
end    
go

grant execute on PD_UpdatePDTrackingData to ExecuteOnlyRole
go


	

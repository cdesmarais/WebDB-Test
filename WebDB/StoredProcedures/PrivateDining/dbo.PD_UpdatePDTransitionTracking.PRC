


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PD_UpdatePDTransitionTracking]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PD_UpdatePDTransitionTracking]
go

create procedure dbo.PD_UpdatePDTransitionTracking 
(
	@RID int	
	,@IsPremiumEnabled bit	
)
as  
  
begin    
	/* 
		Updates free to premium and premium to free transition dates in
		PD tracking table.
		This is procedure is called from OTR ROMS super user page.
		Content owned by India team, please notify asaxena@opentable.com if changing.
	*/
	declare @FreeToPremiumDtUtc datetime 
	declare @PremiumToFreeDtUtc datetime 
	declare @EnableNewPremiumRequest bit

	declare @CurDateUTC datetime
	
	set @CurDateUTC = GETUTCDATE();
	
	set @FreeToPremiumDtUtc = null
	set @PremiumToFreeDtUtc = null
	set @EnableNewPremiumRequest  = 0

	-- if premium enabled for restaurant
	if(@IsPremiumEnabled = 1)
	begin
		-- set free to premium transition date
		set @FreeToPremiumDtUtc = @CurDateUTC
		-- Enable premium request flag for 1st PD submission
		set @EnableNewPremiumRequest = 1
	end
	else
		-- set premium to free transition date
		set @PremiumToFreeDtUtc = @CurDateUTC
		
	-- if PD tracking does not exists for restaurant then insert else update
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
			,@IsPremiumEnabled
			,null
			,null
			,null
			,null
			,@FreeToPremiumDtUtc
			,@PremiumToFreeDtUtc
			,null	
			,null		
			,@EnableNewPremiumRequest
			,null   
		)
	

	end	
	else
		update 
			PDTracking
		set
			FreeToPremiumTransitionDTUTC = @FreeToPremiumDtUtc
			,PremiumToFreeTransitionDTUTC = @PremiumToFreeDtUtc
			,LastSubmissionDtUtc = null
			,EnableNewPremiumRequest  = @EnableNewPremiumRequest
			,IsPremium =   @IsPremiumEnabled
		where
			RID = @RID
	
		
		      
end    
go

grant execute on PD_UpdatePDTransitionTracking to ExecuteOnlyRole
go




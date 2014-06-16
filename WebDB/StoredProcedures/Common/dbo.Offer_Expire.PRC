


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Offer_Expire]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Offer_Expire]
go

--
-- Expire the Offer and Update the Priority of active Offers accordingly.
-- 

create Procedure dbo.Offer_Expire
(
	 @OfferId int		
	,@UpdatedBy nvarchar(32)
)
as

	

	declare @DBError int
	declare @CurrentPriority int
	declare @RID int
	set @RID = 0
	
	
	/* Get the Priority of the Offer to be expired */
	select		
		@CurrentPriority = Priority
		,@RID = RID
	from 
		RestaurantOffer
	where
		RestaurantOfferId = @OfferId
		
	begin transaction

	/* Update Status of the offer to expired. */
	update   
		RestaurantOffer  
	set  
		OfferStatusId = 3 /* 3 = Expired */
		,DisplayOnOTWebsite = 0
		,UpdatedBy = @UpdatedBy
		,UpdatedDTUTC = getutcdate()
	where  
		RestaurantOfferID = @OfferId

	set @DBError = @@error
	if @DBError <> 0
		goto general_error

	/* Move offers which are below the expired offers, upwards by 1 position. */
	Update 
		RestaurantOffer
	set
		Priority = Priority - 1
	where
		Priority < 100
		and Priority > @CurrentPriority
		and RID = @RID

	set @DBError = @@error
	if @DBError <> 0
		goto general_error


	/* Set Priority of expired Offer to null */
	Update 
		RestaurantOffer
	set
		Priority = null
	where
		RestaurantOfferId = @OfferId

	set @DBError = @@error
	if @DBError <> 0
		goto general_error


	commit transaction
	return(0)

general_error:
		rollback transaction	
		return(-1)
go

grant execute on [Offer_Expire] TO ExecuteOnlyRole

go




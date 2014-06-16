

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateRestaurantOffer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateRestaurantOffer]
go

--
-- Updates a RestaurantOffer.  Returns the updated RestaurantOfferID.
-- 

create procedure dbo.UpdateRestaurantOffer
(
	@RestaurantOfferID INT
	,@OfferStatusID	INT
	,@OfferName		NVARCHAR(50)
	,@StartDate		DATETIME
	,@EndDate		DATETIME
	,@Days			VARBINARY(1)
	,@Times00_745	VARBINARY(4)
	,@Times08_1545	VARBINARY(4)
	,@Times16_2345	VARBINARY(4)
	,@DailyMaxCovers	INT
	,@SeatedCovers	INT
	,@PendingCovers	INT
	,@ResoCode		NVARCHAR(20)
	,@OfferDescription	NVARCHAR(500)
	,@MinPartySize	INT
	,@MaxPartySize	INT
	,@ExcludesTaxTip	BIT
	,@NoteToDiners	NVARCHAR(80)
	,@UpdatedBy		NVARCHAR(100)
	,@PostedDate		DATETIME
	,@DisplayOnOTWebsite bit
	,@DisplayOnRestWebsite bit
	,@UpdatedDTUTC datetime output	
)
as	

	/* Get the Current date. */
	set @UpdatedDTUTC = getutcdate()

	update RestaurantOffer
	set
		OfferStatusID = @OfferStatusID
		,OfferName = @OfferName	
		,StartDate = @StartDate
		,EndDate = @EndDate
		,Days = @Days
		,Times00_745 = @Times00_745
		,Times08_1545 = @Times08_1545
		,Times16_2345 = @Times16_2345
		,DailyMaxCovers = @DailyMaxCovers
		,SeatedCovers = @SeatedCovers
		,PendingCovers = @PendingCovers
		,ResoCode = @ResoCode
		,OfferDescription = @OfferDescription
		,MinPartySize = @MinPartySize
		,MaxPartySize = @MaxPartySize
		,ExcludesTaxTip = @ExcludesTaxTip
		,NoteToDiners = @NoteToDiners	
		,UpdatedDtUTC = @UpdatedDTUTC
		,UpdatedBy = @UpdatedBy		
		,DisplayOnOTWebsite = @DisplayOnOTWebsite
		,DisplayOnRestWebsite = @DisplayOnRestWebsite
		,OfferVersion = OfferVersion + 1 /* Increment version number */
	where 
		RestaurantOfferID = @RestaurantOfferID

	-- return the updated ID
	return @RestaurantOfferID

go

grant execute on [UpdateRestaurantOffer] TO ExecuteOnlyRole

go




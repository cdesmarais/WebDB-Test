


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AddRestaurantOffer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AddRestaurantOffer]
GO

--
-- Adds a RestaurantOffer.  Returns the new RestaurantOfferID in the @Result output param
-- 

create Procedure dbo.AddRestaurantOffer
(
	@RID			INT
	,@OfferTypeID	INT
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
	,@CreatedBy		NVARCHAR(100)
	,@DisplayOnOTWebsite bit
	,@DisplayOnRestWebsite bit
	,@RestaurantOfferID INT OUTPUT
	,@CreatedDtUTC datetime output
)
as

	/* Get current date */
	select @CreatedDtUTC = GetUTCDate()

	insert into RestaurantOffer
		(
			RID
			,OfferTypeID
			,OfferStatusID
			,OfferName	
			,StartDate
			,EndDate
			,Days
			,Times00_745
			,Times08_1545
			,Times16_2345
			,DailyMaxCovers
			,SeatedCovers
			,PendingCovers
			,ResoCode
			,OfferDescription
			,MinPartySize
			,MaxPartySize
			,ExcludesTaxTip
			,NoteToDiners
			,CreatedDtUTC
			,UpdatedDtUTC
			,PostedDtUTC
			,CreatedBy
			,Priority
			,DisplayOnOTWebsite
			,DisplayOnRestWebsite
			,OfferVersion
			,UpdatedBy
		)
   values
		(
			@RID
			,@OfferTypeID
			,@OfferStatusID
			,@OfferName	
			,@StartDate
			,@EndDate
			,@Days
			,@Times00_745
			,@Times08_1545
			,@Times16_2345
			,@DailyMaxCovers
			,@SeatedCovers
			,@PendingCovers
			,@ResoCode
			,@OfferDescription
			,@MinPartySize
			,@MaxPartySize
			,@ExcludesTaxTip
			,@NoteToDiners
			,@CreatedDtUTC
			,@CreatedDtUTC /* When new offer is added create date and update date will be same. */
			,@CreatedDtUTC /* Posted to inetrnet date will be same as created date. */
			,@CreatedBy
			,100 /* Set the Priority of newly added Offer to 100 */
			,@DisplayOnOTWebsite
			,@DisplayOnRestWebsite
			,1 /* Offer is newlay added, so set version number to 1 */
			,@CreatedBy /* Updated by user name is same as Created by user name */
		)

	-- return the inserted ID
	set @RestaurantOfferID = SCOPE_IDENTITY()


go

grant execute on [AddRestaurantOffer] TO ExecuteOnlyRole

go



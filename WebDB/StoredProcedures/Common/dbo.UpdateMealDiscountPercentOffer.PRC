

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateMealDiscountPercentOffer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateMealDiscountPercentOffer]
GO

--
-- Updates a MealDiscountPercentOffer.  
-- 

create procedure dbo.UpdateMealDiscountPercentOffer
(
	@OfferStatusID	INT
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
	,@MealDiscountPercent	INT
	,@ApplicableMealDiscountItemID INT
	,@RestaurantOfferID INT
	,@DisplayOnOTWebsite bit
	,@DisplayOnRestWebsite bit
	,@UpdatedDTUTC datetime output
)
as

-- update the base offer record
begin transaction

declare @DBError int

-- Audit Restaurant Offer
exec AddRestaurantOfferAuditLog @RestaurantOfferID
set @DBError = @@error
if @DBError <> 0
	goto general_error

exec UpdateRestaurantOffer @RestaurantOfferID, @OfferStatusID,	@OfferName,	@StartDate,	@EndDate,@Days,
						@Times00_745, @Times08_1545, @Times16_2345,	@DailyMaxCovers, @SeatedCovers,	@PendingCovers,
						@ResoCode, @OfferDescription, @MinPartySize, @MaxPartySize, @ExcludesTaxTip, @NoteToDiners,
						@UpdatedBy,	@PostedDate,@DisplayOnOTWebsite,@DisplayOnRestWebsite,@UpdatedDTUTC output
set @DBError = @@error
if @DBError <> 0
	goto general_error


-- update the type specfic data

update 
	RestaurantOfferMeal
set
	DiscountPercent = @MealDiscountPercent
	,ItemID = @ApplicableMealDiscountItemID
where
	RestaurantOfferID = @RestaurantOfferID

set @DBError = @@error
if @DBError <> 0
	goto general_error

commit transaction
return(0)

general_error:
	rollback transaction	
	return(-1)
go


GRANT EXECUTE ON [UpdateMealDiscountPercentOffer] TO ExecuteOnlyRole

GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AddBeverageDiscountPercentOffer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AddBeverageDiscountPercentOffer]
GO

--
-- Adds a BeverageDiscountPercentOffer.  Returns the new RestaurantOfferID in the @Result output param
-- 

create Procedure dbo.AddBeverageDiscountPercentOffer
(
	@RID			INT,
	@OfferTypeID	INT,
	@OfferStatusID	INT,
	@OfferName		NVARCHAR(50),
	@StartDate		DATETIME,
	@EndDate		DATETIME,
	@Days			VARBINARY(1),
	@Times00_745	VARBINARY(4),
	@Times08_1545	VARBINARY(4),
	@Times16_2345	VARBINARY(4),
	@DailyMaxCovers	INT,
	@SeatedCovers	INT,
	@PendingCovers	INT,
	@ResoCode		NVARCHAR(20),
	@OfferDescription	NVARCHAR(500),
	@MinPartySize	INT,
	@MaxPartySize	INT,
	@ExcludesTaxTip	BIT,
	@NoteToDiners	NVARCHAR(80),	
	@CreatedBy		NVARCHAR(100),
	@ApplicableBeverages varbinary(1),
	@ApplicableBeverageScopeID INT,
	@BeverageDiscountPercent INT,
	@DisplayOnOTWebsite bit,
	@DisplayOnRestWebsite bit,
	@RestaurantOfferID INT OUTPUT,
	@CreatedDTUTC datetime output
)
as

begin transaction

declare @DBError int

-- add the base offer record
exec AddRestaurantOffer @RID, @OfferTypeID,	@OfferStatusID,	@OfferName,	@StartDate,	@EndDate,@Days,
						@Times00_745, @Times08_1545, @Times16_2345,	@DailyMaxCovers, @SeatedCovers,	@PendingCovers,
						@ResoCode, @OfferDescription, @MinPartySize, @MaxPartySize, @ExcludesTaxTip, @NoteToDiners,
						@CreatedBy, @DisplayOnOTWebsite,@DisplayOnRestWebsite, @RestaurantOfferID OUTPUT,@CreatedDTUTC output 

set @DBError = @@error
if @DBError <> 0
	goto general_error

-- add the type specfic data

insert into 
	RestaurantOfferBeverage
	(
		RestaurantOfferID
		,DiscountPercent
		,BeverageScopeID
		,ApplicableBeverages
	)
values
	(
		@RestaurantOfferID
		,@BeverageDiscountPercent
		,@ApplicableBeverageScopeID
		,@ApplicableBeverages
	)


set @DBError = @@error
if @DBError <> 0
	goto general_error

commit transaction
return(0)

general_error:
	rollback transaction	
	return(-1)
go


GRANT EXECUTE ON [AddBeverageDiscountPercentOffer] TO ExecuteOnlyRole

GO


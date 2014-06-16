

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateBuy1Get1Offer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateBuy1Get1Offer]
GO

--
-- Updates a ComplimentaryItem offer.  
-- 

create Procedure dbo.UpdateBuy1Get1Offer
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
	,@Buy1Get1RequiredItemID INT
	,@Buy1Get1DiscountedItemID INT
	,@Buy1Get1DiscountPercent INT
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
	RestaurantOfferBuy1Get1
set
	RequiredItemID = @Buy1Get1RequiredItemID
	,DiscountedItemID = @Buy1Get1DiscountedItemID
	,DiscountPercent = @Buy1Get1DiscountPercent
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

GRANT EXECUTE ON [UpdateBuy1Get1Offer] TO ExecuteOnlyRole

GO




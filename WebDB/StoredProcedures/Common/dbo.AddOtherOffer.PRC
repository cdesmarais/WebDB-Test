

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AddOtherOffer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AddOtherOffer]
GO

--
-- Adds an Other offer.  Returns the new RestaurantOfferID in the @Result output param
-- 

create Procedure dbo.AddOtherOffer
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
	@OtherPricePerPerson DECIMAL(18,2),
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
						@CreatedBy,@DisplayOnOTWebsite,@DisplayOnRestWebsite, @RestaurantOfferID OUTPUT,@CreatedDTUTC output 
set @DBError = @@error
if @DBError <> 0
	goto general_error

-- add the type specfic data

insert into
	RestaurantOfferOther
	(
		RestaurantOfferID,
		PricePerPerson
	)
values
(
	@RestaurantOfferID,
	@OtherPricePerPerson
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


GRANT EXECUTE ON [AddOtherOffer] TO ExecuteOnlyRole

GO


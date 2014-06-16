--Create Stored Proc.
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNResoOffer_Change]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNResoOffer_Change]
GO

CREATE PROCEDURE [dbo].[DNResoOffer_Change]
@ResID                  INT,--Can not be Null
@OfferID                INT,--Can be Null when no offer is attached	
@OfferVersionID			INT--Can be Null when no offer is attached	

AS

DECLARE		@Message	NVARCHAR(3000)

BEGIN TRY
	--Validation
	IF (@OfferID IS NOT NULL AND @OfferVersionID IS NULL)
		RAISERROR('Error: @OfferVersionID can not be Null',16,1)
	IF (@OfferID IS NULL AND @OfferVersionID IS NOT NULL)
		RAISERROR('Error: OfferID can not be Null when other Offer parameters have valid data.',16,1)
	IF (@ResID IS NULL)
		RAISERROR('Error: ResID can not be Null',16,1)

	DECLARE @OfferClassID		INT
	DECLARE @CurrOfferID		INT
	DECLARE @CurrOfferVersionID	INT
	DECLARE @CurrOfferClassID	INT
	
	--Get OfferClassID for the currently associated offer
	SELECT		@CurrOfferClassID = b.OfferClassID 
	FROM		ReservationOffer a WITH (READUNCOMMITTED)
	INNER JOIN	RestaurantOffer b WITH (READUNCOMMITTED)
	ON			a.OfferID = b.RestaurantOfferID
	WHERE		ResID = @ResID
	
	--Get the OfferClassID for the changed Offer
	SELECT	@OfferClassID = OfferClassID 
	FROM	RestaurantOffer WITH (READUNCOMMITTED) 
	WHERE	RestaurantOfferID = @OfferID
	
	IF (@@ROWCOUNT < 1 AND @OfferID IS NOT NULL)
		RAISERROR('Invalid OfferID!',16,1)

	-- Prevent OfferClassID change
	IF (@CurrOfferClassID IS NULL AND @OfferClassID IS NULL)
	 BEGIN --Do nothing and return
		SELECT 1 AS RetVal
		RETURN 1
	 END
	ELSE IF (ISNULL(@CurrOfferClassID,@OfferClassID) <> ISNULL(@OfferClassID,@CurrOfferClassID))--If old/new offer doesn't exist then assume it to be of the same offerclass
		RAISERROR('OfferClassID cannot be changed!',16,1)

	IF (@CurrOfferClassID= 3 OR @OfferClassID = 3)--Village Vines offers
	 BEGIN
		SELECT	@CurrOfferID = OfferID, 
				@CurrOfferVersionID = VersionID 
		FROM	ReservationOffer WITH (READUNCOMMITTED) 
		WHERE	ResID = @ResID
		
		--If there is no change return
		IF	(
				ISNULL(@OfferID,0) = ISNULL(@CurrOfferID,0) AND
				ISNULL(@OfferVersionID,0) = ISNULL(@CurrOfferVersionID,0)
			)
		 BEGIN
			SELECT 1 AS RetVal
			RETURN 1
		 END
		ELSE -- Offer change is not allowed in phase 1
		 BEGIN
			RAISERROR ('Offer change is not allowed!',16,1)
		 END
		
	 END
	ELSE IF (@CurrOfferClassID=2 OR @OfferClassID = 2) -- TopTable Offers
		SET @OfferClassID = 2 -- No-op; execute rest of the proc
	ELSE IF (@CurrOfferClassID = 4 OR @OfferClassID = 4) -- Promoted Offers
		SET @OfferClassID = 4 -- No-op; execute rest of the proc
	ELSE
		RAISERROR('Invalid OfferClassID!',16,1)


	IF (@OfferID IS NOT NULL) --An Offer is associated with the changed Reso
	 BEGIN
		--*****************************************************************
		--Associate the Offer with the Reso 
		--*****************************************************************
		IF NOT EXISTS(SELECT 1 FROM ReservationOffer WITH (READUNCOMMITTED) WHERE ResID=@ResID)
		 BEGIN
			--Insert into ReservationOffer table if it doesn't already exist
			INSERT		ReservationOffer
						(
							ResID,
							OfferID,
							VersionID
						)
			VALUES		(
							@ResID,
							@OfferID,
							@OfferVersionID
						)
		 END
		ELSE
		 BEGIN
			--Update the Offer Associated with the Reso if it exists and there are any changes
			UPDATE		ReservationOffer
			SET			OfferID = @OfferID,
						VersionID = @OfferVersionID
			WHERE		ResID = @ResID
			AND			(
						OfferID <> @OfferID
						OR			
						VersionID <> @OfferVersionID
						)
		 END
		
		
	 END
	ELSE -- No offer is attached to this Reso now so remove the associated Offer if any
	 BEGIN
		--*****************************************************************
		--Disassociate the Offer from the Reso
		--*****************************************************************
		DELETE	ReservationOffer
		WHERE	ResID = @ResID
	 END
	 
	--Returns 1 when Succeded 
	SELECT 1 AS RetVal
	RETURN 1
END TRY

BEGIN CATCH
	SET	@Message = 'Error for ResID:[' + CAST(ISNULL(@ResID, 'NULL') AS VARCHAR) + '] - Message:[' +ISNULL(ERROR_MESSAGE(), '') + ']'
	RAISERROR	(@Message, 16, 1)
	SELECT 0 AS RetVal
	RETURN 0

END CATCH
GO


GRANT EXECUTE ON [DNResoOffer_Change] TO ExecuteOnlyRole

GO

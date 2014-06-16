--Create Stored Proc.
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNResoOffer_Make]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNResoOffer_Make]
GO

CREATE PROCEDURE [dbo].[DNResoOffer_Make]
@ResID                  INT,--Can not be Null
@OfferID                INT,--Can not be Null
@OfferVersionID         INT,--Can not be Null
@OfferConfNumber		INT,--Can be Null (Null for Offers for which inventory is not managed by OT)
@OfferTxnID				INT--Can be Null (Null for Offers for which inventory is not managed by OT)

AS

DECLARE		@Message	NVARCHAR(3000)

BEGIN TRY
	--Validation
	IF (@ResID IS NULL OR @OfferID IS NULL OR @OfferVersionID IS NULL)
		RAISERROR('Error: One of the parameter is Null',16,1)
	IF EXISTS (SELECT 1 FROM dbo.ReservationOffer WITH (READUNCOMMITTED) WHERE ResID=@ResID)
		RAISERROR('Error: ResID already exists',16,1)
	IF EXISTS ( -- Any existing OfferTxn rows with the same OrderNumber that have an associated reso?
			SELECT 1
			FROM OfferTxn WITH (READUNCOMMITTED) 
			WHERE OrderNumber = (SELECT OrderNumber from OfferTxn WITH (READUNCOMMITTED) WHERE OfferTxnID=@OfferTxnID)
			AND MakeConfirmed = 1  
			AND @OfferTxnID > 0
			and @OfferTxnID > 0
		)
		RAISERROR('Error: Reso already exists for Order Number',16,1)	

	--Insert into ReservationOffer table
	INSERT		ReservationOffer
				(
					ResID,
					OfferID,
					VersionID,
					OfferConfNumber,
					OfferTxnID
				)
	VALUES		(
					@ResID,
					@OfferID,
					@OfferVersionID,
					@OfferConfNumber,
					@OfferTxnID
				)

	--Update OfferTxn table				
	IF (@OfferTxnID IS NOT NULL)
	 BEGIN
		UPDATE	OfferTxn
		SET		MakeConfirmed = 1
		WHERE	OfferTxnID = @OfferTxnID 
		AND		MakeConfirmed = 0
		
		IF (@@ROWCOUNT < 1)
		 BEGIN
			IF (EXISTS (SELECT 1 FROM OfferTxn WITH (READUNCOMMITTED) WHERE OfferTxnID = @OfferTxnID AND MakeConfirmed != 0) )
				SET @Message = 'Duplicate Attempt to Set MakeConfirmed; OfferTxnID:[' + ISNULL(CAST(@OfferTxnID AS VARCHAR),'Null') + ']!'
			ELSE
				SET @Message = 'Invalid OfferTxnID:[' + ISNULL(CAST(@OfferTxnID AS VARCHAR),'Null') + '] was found!'
			RAISERROR (@Message,16, 1)
		 END
	 END

	--Returns 1 when Succeeded 
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


GRANT EXECUTE ON [DNResoOffer_Make] TO ExecuteOnlyRole

GO

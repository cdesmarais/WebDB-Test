--Create Stored Proc.
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNResoRedemption_Change]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNResoRedemption_Change]
GO

CREATE PROCEDURE [dbo].[DNResoRedemption_Change]
@ResID						INT,--Can not be Null
@RedemptionID				INT,--Can be Null when no Redemption is attached
@RedemptionName				NVARCHAR(50),--Can be Null when no Redemption is attached
@RedemptionDescription      NVARCHAR(300),--Can be Null when no Redemption is attached
@RedemptionCovers			INT --Can be Null when no Redemption is attached

AS

DECLARE		@Message	NVARCHAR(3000)

BEGIN TRY
	--Validation
	IF (@RedemptionID IS NOT NULL AND (@RedemptionDescription IS NULL OR LEN(@RedemptionDescription) < 1))
		RAISERROR('Error: RedemptionDescription can not be Null or blank',16,1)
	IF (@RedemptionID IS NOT NULL AND (@RedemptionName IS NULL OR LEN(@RedemptionName) < 1))
		RAISERROR('Error: RedemptionName can not be Null or blank',16,1)
	IF (@RedemptionID IS NOT NULL AND (@RedemptionCovers IS NULL OR @RedemptionCovers < 1))
		RAISERROR('Error: @RedemptionCovers has an invalid value',16,1)
	IF (@RedemptionID IS NULL AND (@RedemptionDescription IS NOT NULL OR @RedemptionName IS NOT NULL OR @RedemptionCovers IS NOT NULL))
		RAISERROR('Error: RedemptionID can not be Null when other Redemption parameters have valid data.',16,1)
	IF (@ResID IS NULL)
		RAISERROR('Error: Invalid ResID',16,1)

	IF (@RedemptionID IS NOT NULL) --A Redemption is associated with the changed Reso
	 BEGIN
		--*****************************************************************
		--Associate the Redemption with the Reso
		--*****************************************************************
		IF NOT EXISTS(SELECT 1 FROM ReservationRedemption WHERE ResID=@ResID)
		 BEGIN
			--Insert into ReservationRedemption table if it doesn't already exist
			INSERT		ReservationRedemption
						(
							ResID,
							RedemptionID,
							RedemptionDescription,
							RedemptionCover
						)
			VALUES		(
							@ResID,
							@RedemptionID,
							@RedemptionDescription,
							@RedemptionCovers
						)
		 END
		ELSE
		 BEGIN
			--Update the Redemption Associated with the Reso if it exists and there are any changes
			UPDATE		ReservationRedemption
			SET			RedemptionID = @RedemptionID,
						RedemptionDescription = @RedemptionDescription,
						RedemptionCover = @RedemptionCovers
			WHERE		ResID = @ResID
			AND			(
						RedemptionID <> @RedemptionID
						OR
						RedemptionDescription <> @RedemptionDescription
						OR			
						RedemptionCover <> @RedemptionCovers
						)
		 END	

	 END
	ELSE -- No Redemption is attached to this Reso now so remove the associaion if any
	 BEGIN
	 	--*****************************************************************
		--Disassociate the Redemption from the Reso
		--*****************************************************************
		DELETE	ReservationRedemption
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


GRANT EXECUTE ON [DNResoRedemption_Change] TO ExecuteOnlyRole

GO

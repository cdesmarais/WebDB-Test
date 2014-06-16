--Create Stored Proc.
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNReservationPhoneCountryID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNReservationPhoneCountryID]
GO

CREATE PROCEDURE [dbo].[DNReservationPhoneCountryID]
@ResID                  INT,
@PhoneCountryID			CHAR(2)

AS

DECLARE		@Message	NVARCHAR(3000)

BEGIN TRY
	--Validation
	IF (@ResID IS NULL)
		RAISERROR('Error: @ResID can not be Null',16,1)
		
	IF (@PhoneCountryID IS NULL)
	BEGIN
		DELETE	ReservationPhoneCountryID
		WHERE	ResID = @ResID
	END
	
	ELSE
	BEGIN
		--*****************************************************************
		--Associate the PhoneCountryID with the Reso 
		--*****************************************************************
		IF NOT EXISTS(SELECT 1 FROM ReservationPhoneCountryID WHERE ResID=@ResID)
		 BEGIN
			--Insert into ReservationPhoneCountryID table if it doesn't already exist
			INSERT		ReservationPhoneCountryID
						(
							ResID,
							PhoneCountryID
						)
			VALUES		(
							@ResID,
							@PhoneCountryID
						)
		 END
		ELSE
		 BEGIN
			--Update the PhoneCountryID Associated with the Reso if it exists and there are any changes
			UPDATE		ReservationPhoneCountryID
			SET			PhoneCountryID = @PhoneCountryID
			WHERE		ResID = @ResID
			AND			PhoneCountryID <> @PhoneCountryID				
		 END
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


GRANT EXECUTE ON [DNReservationPhoneCountryID] TO ExecuteOnlyRole

GO

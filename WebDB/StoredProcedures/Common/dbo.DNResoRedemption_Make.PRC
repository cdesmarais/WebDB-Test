--Create Stored Proc.
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNResoRedemption_Make]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNResoRedemption_Make]
GO

CREATE PROCEDURE [dbo].[DNResoRedemption_Make]
@ResID						INT,--Can not be Null
@RedemptionID				INT,--Can not be Null
@RedemptionName				NVARCHAR(50),--Can not be Null
@RedemptionDescription      NVARCHAR(300),--Can not be Null
@RedemptionCovers			INT --Can not be Null

AS

--Insert into ReservationRedemption table

DECLARE		@Message	NVARCHAR(3000)


BEGIN TRY
	--Validation
	IF (@RedemptionDescription IS NULL OR LEN(@RedemptionDescription) < 1)
		RAISERROR('Error: RedemptionDescription can not be Null or blank',16,1)
	IF (@RedemptionName IS NULL OR LEN(@RedemptionName) < 1)
		RAISERROR('Error: RedemptionName can not be Null or blank',16,1)
	IF (@ResID IS NULL OR @RedemptionID IS NULL OR @RedemptionCovers IS NULL)
		RAISERROR('Error: One of the parameter is Null',16,1)
	IF (@RedemptionCovers < 1)
		RAISERROR('Error: The value of @RedemptionCovers should be greater than zero',16,1)
	IF EXISTS (SELECT 1 FROM dbo.ReservationRedemption WHERE ResID=@ResID)
		RAISERROR('Error: ResID already exists in ReservationRedemption table',16,1)


	--Insert into ReservationRedemption table
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


GRANT EXECUTE ON [DNResoRedemption_Make] TO ExecuteOnlyRole

GO

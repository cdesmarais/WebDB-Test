--Create Stored Proc
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[UserSvc_CreateCustomerByEmail]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[UserSvc_CreateCustomerByEmail]
GO

CREATE PROCEDURE [dbo].[UserSvc_CreateCustomerByEmail]

@EMail			NVARCHAR(75),
@MetroAreaID	INT

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
--This proc creates a barebone customer record using just email address.
--It assigns some defaut values for MetroAreaID, PartnerID and ConsumerType

BEGIN TRY
	DECLARE		@GPIdTable TABLE (GPID BIGINT, Created BIT)
	--Retreive the GPID if the user already exists
	INSERT	@GPIdTable (GPID)
	EXEC	[dbo].[UserSvc_RetrieveGpIdByEmail] @EMail
	
	--If we don't find it create barebone Customer
	IF (@@ROWCOUNT = 0)
	 BEGIN
		BEGIN TRAN
			DECLARE		@CustID INT;

			INSERT INTO CallCusNextID (CustomerType) VALUES (1)

			SELECT @CustID = SCOPE_IDENTITY()
			
			IF (@CustID  IS NULL OR @CustID < 1)
				RAISERROR('Could not generate a valid CustID!', 16, 1)

			-- Add record to Customer Table
			INSERT INTO Customer
				(
				CustID
				,EMail
				,Metroareaid
				,PartnerID
				,ConsumerType
				,Points
				)
			VALUES 
				(
				@CustID
				,LTRIM(RTRIM(@Email))
				,@MetroAreaID
				,1 --OT
				,8 --Anonymous
				,0 -- No Points
				)

			--Add record to GlobalPerson table
			INSERT	INTO	GlobalPerson (CustID, CallerID) VALUES(@CustID, NULL)

		COMMIT TRAN
		
		INSERT	@GPIdTable
		SELECT	_GlobalPersonID AS 'GPID',
				1 AS 'Created'
		FROM	dbo.GlobalPerson 
		WHERE	CustID = @CustID
	END
	
	--Return Results
	SELECT		GPID,
				ISNULL(Created, 0) AS Created
	FROM		@GPIdTable
END TRY
BEGIN CATCH
	--Capture the Error Message
	DECLARE @Message NVARCHAR(3000) = ISNULL(ERROR_MESSAGE(), '')
	
	IF (@@TRANCOUNT > 0)
		ROLLBACK TRAN
	
	SET		@Message = @Message + '[' + 'Error creating barebone customer using proc dbo.UserSvc_CreateCustomerByEmail' + ']'
	RAISERROR(@Message, 16, 1)
END CATCH
GO

GRANT EXECUTE ON [UserSvc_CreateCustomerByEmail] TO ExecuteOnlyRole
GO

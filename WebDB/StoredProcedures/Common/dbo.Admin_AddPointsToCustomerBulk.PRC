/**************************************************************
Purpose: Add Points in bulk to Customer/Caller account and 
log entries in pointsadjustment table for audit.
***************************************************************/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[Admin_AddPointsToCustomerBulk]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[Admin_AddPointsToCustomerBulk]
GO

CREATE PROCEDURE dbo.Admin_AddPointsToCustomerBulk
(
  @CharmUserID int = 0,
  @CharmUserEmail varchar(50) = null,
  @SourceIPAddress varchar(50) = null,
  @PointsData dbo.UserPointsTableType READONLY,
  @InactiveAccounts int out,
  @UnknownEmails int out
)
AS

DECLARE @UserID INT,
		@IsCaller INT,
		@Active INT,
		@UserEmail NVARCHAR(75),
		@Points INT,
		@ReasonCode INT,
		@Reason VARCHAR(100),
		
		@InactiveTotal INT = 0,
		@UnknownTotal INT = 0

-- constant always "other"
SET @ReasonCode = 29

DECLARE curs CURSOR FOR SELECT UserEmail, CONVERT(INT, Points), Reason FROM @PointsData
OPEN curs
FETCH NEXT FROM curs INTO @UserEmail, @Points, @Reason

WHILE @@FETCH_STATUS = 0
BEGIN
   
	SET @UserID = null
	SET @Active = null
	-- lookup customer id based on email address
	SELECT @UserID = CallerID, @IsCaller = 1, @Active=CASE WHEN CallerStatusID = 1 THEN 1 ELSE 0 END 
	FROM [Caller] 
	WHERE Email = @UserEmail

	IF @UserID IS NULL
	BEGIN
	   SELECT @UserID = CustID, @IsCaller = 0, @Active = Active
	   FROM Customer 
	   WHERE Email = @UserEmail
	END
	
	-- only apply the points if the customer is found and is active
	IF @UserID IS NOT NULL AND @Active = 1
	BEGIN
		-- delegate actual point adjustment to the other sproc that does individual adjustment
		-- NOTE: This assumes all bulk adjustments are done only to "customers" and not to "callers"
		EXECUTE [dbo].[Admin_AddPointsToCustomer] 
		   @UserID
		  ,@IsCaller
		  ,@Points
		  ,@ReasonCode
		  ,@CharmUserID
		  ,@CharmUserEmail
		  ,@SourceIPAddress
		  ,@Reason

	END
	ELSE
	BEGIN
	   IF (@UserID IS NOT NULL) AND @Active = 0
	      SET @InactiveTotal = @InactiveTotal + 1
	   ELSE
	      SET @UnknownTotal = @UnknownTotal + 1
	END
	
	FETCH NEXT FROM curs INTO @UserEmail, @Points, @Reason
	
END
CLOSE curs;
DEALLOCATE curs;

SET @InactiveAccounts = @InactiveTotal
SET @UnknownEmails = @UnknownTotal

GO


GRANT EXECUTE ON [Admin_AddPointsToCustomerBulk] TO ExecuteOnlyRole
GO
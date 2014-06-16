if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_SetEmailPreferences_v2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_SetEmailPreferences_v2]
GO

-- Set email preferences in UserOptIn table, bit by bit.  
-- If row does not exist for specified user, create it.
-- If NULL is supplied for a preference parameter, it means "don't change this preference"
-- For efficiency, if preference parameters do not require any changes to row,
-- either because they are NULL or are the same as existing values, do not perform the update. 

CREATE PROCEDURE [dbo].User_SetEmailPreferences_v2
(
	@UserID int,  
	@IsCallerOrAdmin bit,
	@Spotlight bit = NULL,
	@Insider bit = NULL,
	@DinersChoice bit = NULL,
	@NewHot bit = NULL,
	@RestaurantWeek bit = NULL,
	@Promotional bit = NULL,
	@Product bit = NULL
)
AS

SET NOCOUNT ON

--**************************************************************************************
--** Begin OBSOLETE LOG
--** The following will log the fact that this obsolete proc was exectured into LogDB..ErrorLog
--** This snippet can be cut and pasted in to any block of code that is thought to be obsolete
--** Embedded in WR12 2011
--**************************************************************************************
	declare @_ErrorMessage nvarchar(1000)
	set @_ErrorMessage = 'PROC called'

	declare @_objName nvarchar(1000)
	SELECT	@_objName = OBJECT_NAME(@@PROCID), 
			@_ErrorMessage = @_ErrorMessage 
							+ ': '+ @_objName
							+ '  by host: ' + rtrim(isnull(hostname, 'unknown'))
							+ '  User: ' + rtrim(isnull(loginame, 'unknown'))
	FROM	sys.sysprocesses 
	WHERE	spid = @@spid  
	exec procLogProcedureError 9, @_objName, 'OBSOLETE', @_ErrorMessage
--**************************************************************************************
--** End OBOSLETE LOG
--**************************************************************************************

DECLARE @ProcName nvarchar(1000)
DECLARE @Action nvarchar(3000)
DECLARE @DBError int
SET @ProcName = 'User_SetEmailPreferences'

BEGIN TRAN

-- Customer/caller primary metro
DECLARE @MetroAreaID int

-- Flag: found existing UserOptIn row for user?
DECLARE @RowFound bit = 0

-- Variables for current values in user's UserOptIn row (before updates):
DECLARE @Cur_Spotlight bit;
DECLARE @Cur_Insider bit;
DECLARE @Cur_DinersChoice bit;
DECLARE @Cur_NewHot bit;
DECLARE @Cur_RestaurantWeek bit;
DECLARE @Cur_Promotional bit;
DECLARE @Cur_Product bit;

-- Variables for new values in user's UserOptIn row (after updates):
DECLARE @New_Spotlight bit;
DECLARE @New_Insider bit;
DECLARE @New_DinersChoice bit;
DECLARE @New_NewHot bit;
DECLARE @New_RestaurantWeek bit;
DECLARE @New_Promotional bit;
DECLARE @New_Product bit;

IF @IsCallerOrAdmin = 1 
	SELECT @MetroAreaID = MetroAreaID FROM dbo.[Caller] WHERE @UserID = CallerID
ELSE
	SELECT @MetroAreaID = MetroAreaID FROM dbo.[Customer] WHERE @UserID = CustID

SET @Action = 'Read current bit values from UserOptIn table'

SELECT 
	@RowFound = 1, 
	@Cur_Spotlight = Spotlight,
	@Cur_Insider = Insider,
	@Cur_DinersChoice = DinersChoice,
	@Cur_NewHot = NewHot,
	@Cur_RestaurantWeek = RestaurantWeek,
	@Cur_Promotional = Promotional,
	@Cur_Product = Product
FROM UserOptIn
WHERE @UserID = 
	CASE @IsCallerOrAdmin 
	WHEN 1 THEN CallerID
	ELSE CustID
	END
	AND MetroAreaID = @MetroAreaID
	
-- If there is no existing UserOptIn row, must create one:
IF (@RowFound = 0)  
BEGIN
	IF (@IsCallerOrAdmin = 1)  -- Must set CallerID
	BEGIN
		SET @Action = 'Insert row for caller or admin into UserOptIn table'
		INSERT INTO UserOptIn (CallerID, MetroAreaID)
		VALUES (@UserID, @MetroAreaID)
	END
	ELSE	-- Must set CustID
	BEGIN
		SET @Action = 'Insert row for customer into UserOptIn table'
		INSERT INTO UserOptIn (CustID, MetroAreaID)
		VALUES (@UserID, @MetroAreaID)
	END
	
	SET @Action = 'Read back defaulted values from UserOptIn table'
	SELECT 
		@Cur_Spotlight = Spotlight,
		@Cur_Insider = Insider,
		@Cur_DinersChoice = DinersChoice,
		@Cur_NewHot = NewHot,
		@Cur_RestaurantWeek = RestaurantWeek,
		@Cur_Promotional = Promotional,
		@Cur_Product = Product
	FROM UserOptIn
	WHERE @UserID = 
		CASE @IsCallerOrAdmin 
		WHEN 1 THEN CallerID
		ELSE CustID
		END
		AND MetroAreaID = @MetroAreaID
END 

-- Determine intended new values in UserOptin row
SET @New_Spotlight = COALESCE(@Spotlight, @Cur_Spotlight)
SET @New_Insider = COALESCE(@Insider, @Cur_Insider)
SET @New_DinersChoice = COALESCE(@DinersChoice, @Cur_DinersChoice)
SET @New_NewHot = COALESCE(@NewHot, @Cur_NewHot)
SET @New_RestaurantWeek = COALESCE(@RestaurantWeek, @Cur_RestaurantWeek)
SET @New_Promotional = COALESCE(@Promotional, @Cur_Promotional)
SET @New_Product = COALESCE(@Product, @Cur_Product)

-- Test to see if any incoming values differ from current UserOptIn values
IF (
	@Cur_Spotlight <> @New_Spotlight OR 
	@Cur_Insider <> @New_Insider OR
	@Cur_DinersChoice <> @New_DinersChoice OR
	@Cur_NewHot <> @New_NewHot OR
	@Cur_RestaurantWeek <> @New_RestaurantWeek OR
	@Cur_Promotional <> @New_Promotional
	)
BEGIN -- There have been changes, update is required

	IF (@IsCallerOrAdmin = 1)  -- caller
	BEGIN
		SET @Action = 'Update row for caller or admin in UserOptIn table'
	END
	ELSE	-- customer
	BEGIN
		SET @Action = 'Update row for customer in UserOptIn table'
	END

	-- Update UserOptIn row columns to incoming values
	-- If incoming value is null, leave column as is
	UPDATE UserOptIn SET
		Spotlight = @New_Spotlight,
		Insider = @New_Insider,
		DinersChoice = @New_DinersChoice,
		NewHot = @New_NewHot,
		RestaurantWeek = @New_RestaurantWeek,
		Promotional = @New_Promotional,
		Product = @New_Product,
		UpdatedDtUTC = GETUTCDATE()
	WHERE @UserID = 
		CASE @IsCallerOrAdmin 
		WHEN 1 THEN CallerID
		ELSE CustID
	END
		AND MetroAreaID = @MetroAreaID

END

-- vvvvvvvvvvvvvvvvvvvvvvvvvv TEMPORARY WRAPUP CODE vvvvvvvvvvvvvvvvvvvvvvvvvv
-- Delete this section when [SendAnnouncements] column in cust/caller tables is phased out 

DECLARE @Must_Sync bit = 0
DECLARE @SendAnnouncements bit = 0

-- If all UserOptin bits are 1, must sync SendAnnouncements to 1
IF (
--	(@New_Spotlight = 1) AND  << Spotlight is temporarily ignored for this purpose 9/2/2010
	(@New_Insider = 1) AND
	(@New_DinersChoice = 1) AND
	(@New_NewHot = 1) AND
	(@New_RestaurantWeek = 1) AND
	(@New_Promotional = 1)
	)
BEGIN
	SET @Must_Sync = 1
	SET @SendAnnouncements = 1	
END

-- If all UserOptin bits are 0, must sync SendAnnouncements to 0
IF (
--	(@New_Spotlight = 0) AND  << Spotlight is temporarily ignored for this purpose 9/2/2010
	(@New_Insider = 0) AND
	(@New_DinersChoice = 0) AND
	(@New_NewHot = 0) AND
	(@New_RestaurantWeek = 0) AND
	(@New_Promotional = 0)
	)
BEGIN
	SET @Must_Sync = 1
	SET @SendAnnouncements = 0
END

IF (@Must_Sync = 1)
BEGIN
	IF (@IsCallerOrAdmin = 1)
	BEGIN
		SET @Action = 'Sync SendAnnouncements field in Caller table'
		UPDATE [Caller] 
		SET SendAnnouncements = @SendAnnouncements
		WHERE CallerID = @UserID AND SendAnnouncements <> @SendAnnouncements
	END
	ELSE
	BEGIN
		SET @Action = 'Sync SendAnnouncements field in Customer table'
		UPDATE [Customer] 
		SET SendAnnouncements = @SendAnnouncements
		WHERE CustID = @UserID AND SendAnnouncements <> @SendAnnouncements
	END
END
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^ TEMPORARY WRAPUP CODE ^^^^^^^^^^^^^^^^^^^^^^^^^^

SET @DBError = @@ERROR
IF @DBError <> 0
	GOTO general_error

COMMIT TRAN
RETURN(0)

general_error:
	ROLLBACK TRANSACTION
	EXEC procLogProcedureError 1, @ProcName, @Action, @DBError
	RETURN(0)
GO

GRANT EXECUTE ON [User_SetEmailPreferences_v2] TO ExecuteOnlyRole
GO
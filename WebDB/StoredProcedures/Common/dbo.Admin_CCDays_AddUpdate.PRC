if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_CCDays_AddUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_CCDays_AddUpdate]
GO

-- Procedure adds/updates/deletes credit card days
-- RID, BlockedDate, PartySize
CREATE PROCEDURE dbo.Admin_CCDays_AddUpdate
	@CCDayID int = 0,	-- Credit Card Day ID.
	@RestaurantID int, 		-- restaurantID of restaurant who's date is being customed
	@BlockedDate datetime, 		-- date being customed
	@ShiftStart datetime = null,-- shift start time
	@ShiftEnd datetime = null,	-- shift end time
	@PartySize int,			-- party size for which credit card is required
	@BlockedBy nvarchar(50),		-- who blocked it
	@Messages nvarchar (4000),		-- custom messages
	@LanguagesID nvarchar (4000),	-- custom messages languages
	@Retval int OUTPUT
AS

SET NOCOUNT ON

-- determine if we need to update or insert..

declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError int
declare @IsUpdate int
set @IsUpdate=0

set @ProcName = 'Admin_CCDays_AddUpdate'

if @Messages is NULL
	BEGIN
		Set @Messages = ''
	END

IF EXISTS (
		SELECT CCDayID FROM dbo.CreditCardDay
		WHERE RID = @RestaurantID AND CCDayID <> @CCDayID AND BlockedDate = @BlockedDate AND (
			(@ShiftStart <= StartTime AND @ShiftEnd >= EndTime) OR
			(@ShiftStart >= StartTime AND @ShiftStart <= EndTime) OR 
			(@ShiftEnd >= StartTime AND @ShiftEnd <= EndTime) OR 
			(StartTime IS NULL AND EndTime IS NULL) OR 
			(@ShiftStart IS NULL AND @ShiftEnd IS NULL)))
	BEGIN
		goto overlapping_shift
	END

BEGIN TRANSACTION
-- check if a record exists for this rid/cc combination..if it does delete it first
if @CCDayID=0
	BEGIN
		-- insert cc day..
		set @Action = 'insert into CreditCardDay'
		Insert into CreditCardDay (RID, BlockedDate, StartTime, EndTime, BlockedBy, PartySize) 
		VALUES (@RestaurantID, @BlockedDate, @ShiftStart, @ShiftEnd, @BlockedBy, @PartySize)

		set @DBError = @@error
		if @DBError <> 0
			goto general_error
		Set @CCDayID = scope_identity()

		-- insert cc day local..
		set @Action = 'INSERT INTO CreditCardDayLocal'
		Insert into CreditCardDaylocal (DayID, Message, LanguageID) 
			select @CCDayID, [Value], [Key] from dbo.fMergeListsToTab(@LanguagesID, @Messages, '^', '^')
		set @DBError = @@error
		if @DBError <> 0
			goto general_error
	END
else
	BEGIN

		-- update cc day..
		set @Action = 'update CreditCardDay'
		UPDATE CreditCardDay SET 
			BlockedDate = @BlockedDate,
			StartTime = @ShiftStart,
			EndTime = @ShiftEnd,
			BlockedBy = @BlockedBy, 
			PartySize = @PartySize
		WHERE CCDayID = @CCDayID

		set @DBError = @@error
		if @DBError <> 0
			goto general_error

		-- insert customed day local..
		set @Action = 'update CreditCardDayLocal'
		Delete from CreditCardDayLocal where DayID = @CCDayID
		Insert into CreditCardDaylocal (DayID, Message, LanguageID) 
			select @CCDayID, [Value], [Key] from dbo.fMergeListsToTab(@LanguagesID, @Messages, '^', '^')
		set @DBError = @@error
		if @DBError <> 0
			goto general_error
	END

set @RetVal = @CCDayID

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	exec procLogProcedureError 1, @ProcName, @Action, @DBError
	Return(0)

overlapping_shift:
	ROLLBACK TRANSACTION
	set @RetVal = -1
	Return(0)
GO

GRANT EXECUTE ON [Admin_CCDays_AddUpdate] TO ExecuteOnlyRole

GO
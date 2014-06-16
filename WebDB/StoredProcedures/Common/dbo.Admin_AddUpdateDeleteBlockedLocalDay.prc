if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_AddUpdateDeleteBlockedLocalDay]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_AddUpdateDeleteBlockedLocalDay]
GO

-- Procedure adds/updates/deletes blocked dates
CREATE PROCEDURE dbo.Admin_AddUpdateDeleteBlockedLocalDay
	@RestaurantID int, 		-- restaurantID of restaurant who's date is being customed
	@BlockedDate datetime, 		-- date being customed
	@Messages nvarchar (4000),	-- custom messages
	@LanguagesID nvarchar (500),	-- custom messages languages
	@BlockedBy nvarchar(50),	-- who customed it
	@IsDelete int,			-- are we deleting the customed day? If set to 1, the customed day will be deleted
	@BlockReason int		-- Blocked Day Reason
AS

SET NOCOUNT ON

BEGIN TRANSACTION

-- determine if we need to update or insert..

declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError int
declare @IsUpdate int, @Dayid int
set @IsUpdate=0

set @ProcName = 'Admin_AddUpdateDeleteBlockedLocalDay'

-- check if a record exists for this rid/customedday combination..if it does delete it first
if exists(select * from BlockedDayVW where RID = @RestaurantID and BlockedDate =@BlockedDate) OR @IsDelete=1
	BEGIN
		-- delete and then insert..
		DELETE FROM [BlockedDaylocal] WHERE DayID IN (
		SELECT DayID FROM [BlockedDay] WHERE RID = @RestaurantID AND BlockedDate = @BlockedDate
		)
		If @@Error <> 0 
			goto general_error

		DELETE FROM [BlockedDay] WHERE RID = @RestaurantID AND BlockedDate = @BlockedDate
		If @@Error <> 0 
			goto general_error
	END

-- insert a new record only if its NOT a delete
if @IsDelete=0
	BEGIN

		-- insert customed day..
		Insert into BlockedDay (RID, BlockedDate,BlockedBy,BlockReason) 
		VALUES (@RestaurantID,@BlockedDate,@BlockedBy,@BlockReason)

		Set @Dayid = scope_identity()
		set @DBError = @@error
		if @DBError <> 0
			goto general_error

		-- insert customed day local..
		Insert into BlockedDaylocal (DayID, Message, LanguageID)  
			select @Dayid, [Value], [Key] from dbo.fMergeListsToTab(@LanguagesID, @Messages, '^', '^')
		set @DBError = @@error
		if @DBError <> 0
			goto general_error
	END



COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	exec procLogProcedureError 1, @ProcName, @Action, @DBError
	Return(0)

GO

GRANT EXECUTE ON [Admin_AddUpdateDeleteBlockedLocalDay] TO ExecuteOnlyRole

GO

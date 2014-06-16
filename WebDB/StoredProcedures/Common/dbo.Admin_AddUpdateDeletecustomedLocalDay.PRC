if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_AddUpdateDeletecustomedLocalDay]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_AddUpdateDeletecustomedLocalDay]
GO

-- Procedure adds/updates/deletes blocked dates
CREATE PROCEDURE dbo.Admin_AddUpdateDeletecustomedLocalDay
	@RestaurantID int, 		-- restaurantID of restaurant who's date is being customed
	@customedDate datetime, 	-- date being customed
	@Messages nvarchar (4000),	-- custom message
	@LanguagesID nvarchar (500),	-- custom message
	@customedBy nvarchar(50),	-- who customed it
	@IsDelete int,			-- are we deleting the customed day? If set to 1, the customed day will be deleted
	@IsDetailsPageOnly int		-- is this msg only for display on the Reservation Details page?
AS

SET NOCOUNT ON

BEGIN TRANSACTION

-- determine if we need to update or insert..

declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError int
declare @IsUpdate int, @Dayid int
set @IsUpdate=0

set @ProcName = 'Admin_AddUpdateDeleteCustomedLocalDay'

-- delete and then insert..
set @Action = 'Delete local customed day if exist'
DELETE FROM [customedDaylocal] WHERE DayID IN (
SELECT DayID FROM [customedDay] WHERE RID = @RestaurantID AND customedDate = @customedDate
)
If @@Error <> 0 
	goto general_error

set @Action = 'Delete customed day if exist'
DELETE FROM [customedDay] WHERE RID = @RestaurantID AND customedDate = @customedDate
If @@Error <> 0 
	goto general_error

-- insert a new record only if its NOT a delete
if @IsDelete=0
	BEGIN

		-- insert customed day..
		Insert into customedDay (RID, customedDate,customedBy, DetailsPageOnly) 
		VALUES (@RestaurantID,@customedDate,@customedBy, @IsDetailsPageOnly)

		Set @Dayid = scope_identity()
		set @DBError = @@error
		if @DBError <> 0
			goto general_error

		-- insert customed day local..
		Insert into customedDaylocal (DayID, Message, LanguageID) 
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

GO

GRANT EXECUTE ON [Admin_AddUpdateDeletecustomedLocalDay] TO ExecuteOnlyRole

GO

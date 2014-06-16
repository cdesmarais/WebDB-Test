if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_AddUpdateDeleteBlockedDay]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_AddUpdateDeleteBlockedDay]
GO

-- Procedure adds/updates/deletes blocked dates
CREATE PROCEDURE dbo.Admin_AddUpdateDeleteBlockedDay
@RestaurantID int, 		-- restaurantID of restaurant who's date is being blocked
@BlockedDate datetime, 		-- date being blocked
@Message nvarchar (500),	-- block message
@BlockedBy nvarchar(50),	-- who blocked it
@IsDelete int,			-- are we deleting the blocked day? If set to 1, the blocked day will be deleted
@BlockReason int		-- Blocked Day Reason
AS

SET NOCOUNT ON

BEGIN TRANSACTION

-- determine if we need to update or insert..
declare @IsUpdate int
set @IsUpdate=0

declare @LanguageID int
exec @LanguageID = procGetDBUserLanguageID  

declare @DayID int
declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError int
set @ProcName = 'Admin_AddUpdateDeleteBlockedDay'

-- check if a record exists for this rid/blockedday combination..if it does delete it first

if exists(select * from BlockedDay where RID = @RestaurantID and BlockedDate =@BlockedDate) OR @IsDelete=1
	BEGIN
		-- delete and then insert..
		set @Action = 'Delete BlockDayLocal & BlockDay tables'				
		delete from BlockedDayLocal where dayID in (select DayID from BlockedDay where RID = @RestaurantID and BlockedDate =@BlockedDate)
		delete from BlockedDay where RID = @RestaurantID and BlockedDate =@BlockedDate
		
		set @DBError = @@ERROR
		if @DBError <> 0 goto error		
	END

-- insert a new record only if its NOT a delete
if @IsDelete=0
	BEGIN
		-- insert blocked day..
		set @Action = 'Insert Record into BlockDay & BlockedDayLocal tables'
		Insert into BlockedDay (RID, BlockedDate, BlockedBy,BlockReason) 
		VALUES (@RestaurantID,@BlockedDate,@BlockedBy,@BlockReason)
		
		SELECT @DayID = scope_identity()		
	
		Insert into BlockedDaylocal (DayID, Message, LanguageID) values (@Dayid, @Message, @LanguageID)
		
		set @DBError = @@ERROR
		if @DBError <> 0 goto error	
	END

COMMIT TRANSACTION
RETURN(0)

error:
	ROLLBACK TRANSACTION
	exec procLogProcedureError 1, @ProcName, @Action, @DBError
	Return(1)
GO

GRANT EXECUTE ON [Admin_AddUpdateDeleteBlockedDay] TO ExecuteOnlyRole
GO

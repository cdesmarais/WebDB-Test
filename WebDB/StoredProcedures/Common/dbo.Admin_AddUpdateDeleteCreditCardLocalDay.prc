if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_AddUpdateDeleteCreditCardLocalDay]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_AddUpdateDeleteCreditCardLocalDay]
GO

-- Procedure adds/updates/deletes credit card days
-- RID, BlockedDate, PartySize
CREATE PROCEDURE dbo.Admin_AddUpdateDeleteCreditCardLocalDay
	@RestaurantID int, 		-- restaurantID of restaurant who's date is being customed
	@BlockedDate datetime, 		-- date being customed
	@PartySize int,			-- party size for which credit card is required
	@BlockedBy nvarchar(50),		-- who blocked it
	@IsDelete int,			-- are we deleting the credit card day? If set to 1, the credit card day will be deleted
	@Messages nvarchar (4000),		-- custom messages
	@LanguagesID nvarchar (4000)		-- custom messages languages


AS

SET NOCOUNT ON

BEGIN TRANSACTION

-- determine if we need to update or insert..

declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError int
declare @IsUpdate int, @Dayid int
set @IsUpdate=0

set @ProcName = 'Admin_AddUpdateDeleteCreditCardLocalDay'

-- check if a record exists for this rid/cc combination..if it does delete it first
if exists(select * from CreditCardDay where RID = @RestaurantID and BlockedDate =@BlockedDate) OR @IsDelete=1
	BEGIN
		-- delete and then insert..
		set @Action = 'Delete local credit card day info if exist'
		DELETE FROM [CreditCardDaylocal] WHERE DayID IN (
		SELECT CCDayID FROM [CreditCardDay] WHERE RID = @RestaurantID AND BlockedDate = @BlockedDate
		)
		If @@Error <> 0 
			goto general_error

		set @Action = 'Delete credit card day if exist'
		DELETE FROM [CreditCardDay] WHERE RID = @RestaurantID AND BlockedDate = @BlockedDate
		If @@Error <> 0 
			goto general_error
	END

-- insert a new record only if its NOT a delete
if @IsDelete=0
	BEGIN

		-- insert cc day..
		set @Action = 'insert into CreditCardDay'
		Insert into CreditCardDay (RID, BlockedDate,BlockedBy, PartySize) 
		VALUES (@RestaurantID,@BlockedDate,@BlockedBy,@PartySize)

		Set @Dayid = scope_identity()
		set @DBError = @@error
		if @DBError <> 0
			goto general_error

		-- insert customed day local..
		set @Action = 'INSERT INTO CreditCardDayLocal'
		Insert into CreditCardDaylocal (DayID, Message, LanguageID) 
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

GRANT EXECUTE ON [Admin_AddUpdateDeleteCreditCardLocalDay] TO ExecuteOnlyRole

GO

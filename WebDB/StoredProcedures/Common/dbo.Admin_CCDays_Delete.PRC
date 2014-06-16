if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_CCDays_Delete]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_CCDays_Delete]
GO




CREATE PROCEDURE dbo.Admin_CCDays_Delete 

@restaurant_id int,
@UncustomAll int,
@Assignment_Date datetime

AS

BEGIN TRANSACTION

DECLARE @DBError int
DECLARE @ProcName as nvarchar(100)
DECLARE @Action as nvarchar(100)

SET @ProcName = 'Admin_CCDays_Delete'

if @UncustomAll = 1 
	BEGIN

		-- delete and then insert..
		SET @Action = 'Delete all CCDays for RID'
		DELETE FROM [CreditCardDaylocal] WHERE DayID IN (
		SELECT CCDayID FROM [CreditCardDay] WHERE RID = @restaurant_id
		)

		DELETE FROM [CreditCardDay] WHERE RID = @restaurant_id



	END
else
	BEGIN
		SET @Action = 'Delete all CCDays for RID on Blocked Date'
		DELETE FROM [CreditCardDaylocal] WHERE DayID IN (
		SELECT CCDayID FROM [CreditCardDay] WHERE RID = @restaurant_id AND BlockedDate = @Assignment_Date
		)

		DELETE FROM [CreditCardDay] WHERE RID = @restaurant_id AND BlockedDate = @Assignment_Date

	END

SET @DBError = @@error
	
IF @DBError <> 0 
	GOTO general_error

COMMIT TRANSACTION	
RETURN(0)

general_error:
	ROLLBACK TRANSACTION	
	EXEC procLogProcedureError 1, @ProcName, @Action, @DBError
	RETURN(@@error)
GO

GRANT EXECUTE ON [Admin_CCDays_Delete] TO ExecuteOnlyRole

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_CCDays_Delete_byID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_CCDays_Delete_byID]
GO

CREATE PROCEDURE dbo.Admin_CCDays_Delete_byID
(
@CCDayID int
)
AS

BEGIN TRANSACTION

	DECLARE @DBError int
	DECLARE @ProcName as nvarchar(100)
	DECLARE @Action as nvarchar(100)
	
	SET @ProcName = 'Admin_CCDays_Delete_byID'
	SET @Action = 'Delete CCDays by ID'
	
	DELETE FROM [CreditCardDaylocal] WHERE DayID = @CCDayID

	DELETE FROM [CreditCardDay] WHERE CCDayID = @CCDayID
	
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

GRANT EXECUTE ON [Admin_CCDays_Delete_byID] TO ExecuteOnlyRole

GO

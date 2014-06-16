if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_MacroActivate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_MacroActivate]
GO




CREATE PROCEDURE dbo.Admin_MacroActivate

(@active bit,
 @Macro_ID int=0
 )

AS
SET NOCOUNT ON

declare @dbActive bit
select @dbActive = Active from MacroNeighborhood where MacroID = @Macro_ID
	
BEGIN TRANSACTION

	update MacroNeighborhood set active = @active where MacroID = @Macro_ID
	if (@@ERROR <> 0)
	goto general_error	
	
	if(@active = 0 and @dbActive = 1) --if the active flag has changed	
		INSERT INTO OTTopTenSchemaAudit (macroid, operationtypeid) --write to audit log table
		VALUES (@Macro_ID, 3)

	if (@@ERROR <> 0)
		goto general_error
	
	if(@active = 1 and @dbActive = 0)	
		INSERT INTO OTTopTenSchemaAudit (macroid, operationtypeid) --write to audit log table
		VALUES (@Macro_ID, 4)
	
	if (@@ERROR <> 0)
		goto general_error
	
COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Admin_MacroActivate] TO ExecuteOnlyRole

GO

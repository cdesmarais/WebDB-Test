if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Neighborhood_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Neighborhood_Update]
GO




CREATE PROCEDURE dbo.Admin_Neighborhood_Update
 (
  @Name nvarchar(50),
  @SName nvarchar(50),
  @Active bit,
  @Macro_ID int = 0,
  @Neighborhood_ID int
 )
As

SET NOCOUNT ON
if @Macro_ID = 0
BEGIN
	Set @Macro_ID = null
End

BEGIN TRANSACTION
declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError int


set @ProcName = 'Admin_Neighborhood_Update'

--**********************
--** Get Language
--**********************
set @Action = 'Retrieve LanguageID'
declare @LanguageID int
exec @LanguageID = procGetDBUserLanguageID
set @DBError = @@error
if @DBError <> 0
	goto general_error

--**********************
--** Update Master
--**********************
set @Action = 'UPDATE Neighborhood'

UPDATE Neighborhood 
SET 
  Active = @Active,
  MacroID = @Macro_ID
WHERE neighborhoodid = @Neighborhood_ID
set @DBError = @@error
if @DBError <> 0
	goto general_error


--**********************
--** Update Local
--**********************
set @Action = 'UPDATE NeighborhoodLocal'

UPDATE NeighborhoodLocal
SET 	NbHoodName = @Name,
	NbhoodSName = rtrim(ltrim(@SName))
WHERE	neighborhoodid = @Neighborhood_ID
and		LanguageID = @LanguageID
set @DBError = @@error
if @DBError <> 0
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	exec procLogProcedureError 1, @ProcName, @Action, @DBError
	Return(0)
GO

GRANT EXECUTE ON [Admin_Neighborhood_Update] TO ExecuteOnlyRole

GO

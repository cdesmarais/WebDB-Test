if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_MacroAdd]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_MacroAdd]
GO




CREATE PROCEDURE dbo.Admin_MacroAdd 
(
  @macroname nvarchar(100),
  @active bit,
  @metroID int,
  @retval int =1 OUTPUT
)
AS

BEGIN TRANSACTION
declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError int
declare @id int


 --check for dup nicknames
  IF EXISTS (	Select	MacroID 
				from	MacroNeighborhoodAVW
				where	MacroName = @macroname 
				And	metroareaid = @metroID
			) 
      Begin
          RAISERROR ('The Macro Neighborhood you have selected is already in use',1,2)
          ROLLBACK TRANSACTION
          Select @ID = 0
          Select retval = @ID
          RETURN(1)
      End

--**********************
--** Insert into Local
--**********************
set @Action = 'INSERT INTO MacroNeighborhood'

Insert Into MacroNeighborhood (
	Active,
	metroareaid
)
Values
(
	@active,
	@metroID
)
set @DBError = @@error
set @id = scope_identity()
if @DBError <> 0
	goto general_error

--**********************
--** Insert into Local for all Languages Metro Exists
--**********************
set @Action = 'INSERT INTO MacroNeighborhoodLocal'

insert into MacroNeighborhoodLocal (
	MacroID,
	LanguageID,
	MacroName
)
Select 	@ID as MacroID,
	LanguageID,
	@macroname as MacroName
from 	Metroarealocal
where 	MetroareaID = @metroID


set @DBError = @@error
if @DBError <> 0
	goto general_error



COMMIT TRANSACTION
SELECT @retval = @id
Return(0)

general_error:
	ROLLBACK TRANSACTION
	exec procLogProcedureError 1, @ProcName, @Action, @DBError
	Return(0)
GO


GRANT EXECUTE ON [Admin_MacroAdd] TO ExecuteOnlyRole

GO

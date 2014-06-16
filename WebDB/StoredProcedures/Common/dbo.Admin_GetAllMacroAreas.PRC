if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetAllMacroAreas]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetAllMacroAreas]
GO




CREATE PROCEDURE dbo.Admin_GetAllMacroAreas
(
  @MetroID int
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Declare @Languages AS int

if @MetroID = 0
BEGIN
	Select @Languages = count(DISTINCT LanguageID) from MacroNeighborhoodLocal
	Select	MacroID as Macro_ID,
			MacroName as Macro_Name,
		@Languages as Languages, metroareaid
	From	MacroNeighborhoodVW mn
	Order By metroareaid Asc, MacroName Asc

END
else
BEGIN
	select @Languages = count(DISTINCT LanguageID) from MacroNeighborhoodLocal ml
	inner join MacroNeighborhood m on m.MacroID = ml.macroID
	where metroAreaID = @MetroID

	Select	MacroID as Macro_ID,
			MacroName as Macro_Name,
		@Languages as Languages
	From	MacroNeighborhoodVW mn
	Where	metroareaid = @MetroID
	Order By MacroName Asc



END


GO

GRANT EXECUTE ON [Admin_GetAllMacroAreas] TO ExecuteOnlyRole

GO

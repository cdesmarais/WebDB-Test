if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Macro_UpdateAll]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Macro_UpdateAll]
GO

CREATE PROCEDURE dbo.Admin_Macro_UpdateAll
(
  @macroid int,
  @macroName nvarchar(100),
  @sortorder int
)
AS

declare @LanguageID int
exec @LanguageID = procGetDBUserLanguageID

Update	MacroNeighborhood 
set		SortOrder = @sortorder 
where	MacroID = @macroid

Update	MacroNeighborhoodlocal
set		MacroName = @macroName 
where	MacroID = @macroid
and	LanguageID = @LanguageID

GO

GRANT EXECUTE ON [Admin_Macro_UpdateAll] TO ExecuteOnlyRole

GO

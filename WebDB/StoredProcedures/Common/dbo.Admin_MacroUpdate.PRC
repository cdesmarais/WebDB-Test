if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_MacroUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_MacroUpdate]
GO

CREATE PROCEDURE dbo.Admin_MacroUpdate
(
  @macroid int,
  @macroName nvarchar(100),
  @sortorder INT,
  @active int
)
AS

declare @LanguageID int
exec @LanguageID = procGetDBUserLanguageID

if @sortorder = 99
BEGIN
	Set @sortorder = NULL
END

Update	MacroNeighborhood 
set		SortOrder = @sortorder,
		Active = @active 
where	MacroID = @macroid

Update	MacroNeighborhoodlocal
set		MacroName = @macroName 
where	MacroID = @macroid
and	LanguageID = @LanguageID

GO

GRANT EXECUTE ON [Admin_MacroUpdate] TO ExecuteOnlyRole

GO

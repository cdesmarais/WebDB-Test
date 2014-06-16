if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Macro_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Macro_Update]
GO





CREATE PROCEDURE dbo.Admin_Macro_Update
(
  @macroid int,
  @sortorder int
)
AS

Update	MacroNeighborhood 
set		SortOrder = @sortorder 
where	MacroID = @macroid


GO

GRANT EXECUTE ON [Admin_Macro_Update] TO ExecuteOnlyRole

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Macro_AssignNeighborhood]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Macro_AssignNeighborhood]
GO

CREATE PROCEDURE dbo.Admin_Macro_AssignNeighborhood
(
  @neighborhoodID nvarchar(999),
  @MacroID int
)
AS

set nocount on
--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRANSACTION
Update Neighborhood
Set    MacroID = Null
Where  MacroID = @MacroID

Update Neighborhood
Set MacroID = @MacroID
Where CHARINDEX(',' + CAST(NeighborhoodID AS nvarchar(500))+ ',',',' + @neighborhoodID + ',') > 0
if (@@ERROR <> 0)
goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Admin_Macro_AssignNeighborhood] TO ExecuteOnlyRole

GO

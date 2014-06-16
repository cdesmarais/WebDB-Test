if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Delete_MacroNeighborhood]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Delete_MacroNeighborhood]
GO


CREATE PROCEDURE dbo.Delete_MacroNeighborhood
(
    @MacroID int
)

AS


Delete from NeighborhoodLocal where NeighborhoodID in (
Select NeighborhoodID from Neighborhood where MacroID = @MacroID)
Delete from Neighborhood where MacroID = @MacroID
Delete from MacroNeighborhoodLocal where MacroID = @MacroID
Delete from MacroNeighborhood where MacroID = @MacroID

GO

GRANT EXECUTE ON [Delete_MacroNeighborhood] TO ExecuteOnlyRole

GO

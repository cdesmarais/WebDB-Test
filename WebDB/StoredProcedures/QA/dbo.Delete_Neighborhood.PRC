if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Delete_Neighborhood]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Delete_Neighborhood]
GO


CREATE PROCEDURE dbo.Delete_Neighborhood
(
    @NeighborhoodID int
)

AS

Delete from NeighborhoodLocal where NeighborhoodID = @NeighborhoodID
Delete from Neighborhood where NeighborhoodID = @NeighborhoodID


GO

GRANT EXECUTE ON [Delete_Neighborhood] TO ExecuteOnlyRole

GO

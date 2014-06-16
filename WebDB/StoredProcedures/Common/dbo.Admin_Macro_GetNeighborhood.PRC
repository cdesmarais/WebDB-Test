if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Macro_GetNeighborhood]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Macro_GetNeighborhood]
GO


CREATE PROCEDURE dbo.Admin_Macro_GetNeighborhood
(
  @MetroID int,
  @MacroID int
)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT DISTINCT 
			neighborhoodid as Neighborhood_ID,
			NbhoodName as Name,
			MacroID as Macro_ID,
			NbhoodSName as SName
FROM		NeighborhoodVW n
WHERE		metroareaid = @MetroID 
AND			Active = 1 
AND			(MacroID Is Null OR MacroID = @MacroID)
Order By	Name Asc

Return(0)

GO

GRANT EXECUTE ON [Admin_Macro_GetNeighborhood] TO ExecuteOnlyRole

GO

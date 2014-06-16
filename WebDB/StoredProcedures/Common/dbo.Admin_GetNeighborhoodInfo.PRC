if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetNeighborhoodInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetNeighborhoodInfo]
GO




CREATE PROCEDURE dbo.Admin_GetNeighborhoodInfo
(
  @Neighborhood_ID int
)
 AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT DISTINCT 
			m.MetroAreaName as Metrocity,
			n.NbhoodName as Neighborhood,
			n.NbhoodSName as SName,
			n.Active as Active,
			n.neighborhoodid as Neighborhood_ID,
			n.MacroID as Macro_ID,
			n.LanguageID,
			m.PrimaryLanguageID,
			m.metroareaid
FROM		NeighborhoodAVW n
inner join	MetroAreaAVW m 
on			m.metroareaid = n.metroareaid
and			m.LanguageID = n.LanguageID
WHERE		n.neighborhoodid = @Neighborhood_ID
ORDER BY	n.LanguageID

Return(0)

GO

GRANT EXECUTE ON [Admin_GetNeighborhoodInfo] TO ExecuteOnlyRole

GO

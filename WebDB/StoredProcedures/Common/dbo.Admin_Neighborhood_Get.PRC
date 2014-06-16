if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Neighborhood_Get]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Neighborhood_Get]
GO




CREATE PROCEDURE dbo.Admin_Neighborhood_Get
 (
  @metroareaid int
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Declare @Languages AS int
Select @Languages = count(DISTINCT MacroNeighborhoodAVW.LanguageID) from MacroNeighborhoodAVW
inner join [Language] l
on			l.languageID = MacroNeighborhoodAVW.languageID
where l.active = 1 and metroareaid = @metroareaid


SELECT		ma.MetroAreaName as Metrocity
			,n.NbhoodName as Neighborhood
			,n.NbhoodSName as SName
			,mn.MacroName as Macro_Name
			,n.Active as Active
			,n.neighborhoodid as neighborhood_id
			,n.MacroID as Macro_ID, 
			@Languages as Languages
FROM		NeighborhoodVW n
Left Join	MacroNeighborhoodAVW mn 
on			mn.MacroID = n.MacroID
and			mn.LanguageID = n.LanguageID
Inner Join	MetroAreaAVW ma
on			ma.metroareaid = n.metroareaid
and			ma.LanguageID = n.LanguageID
WHERE		ma.metroareaid = @metroareaid

Return(0)

GO

GRANT EXECUTE ON [Admin_Neighborhood_Get] TO ExecuteOnlyRole

GO

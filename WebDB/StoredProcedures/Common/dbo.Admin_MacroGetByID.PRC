if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_MacroGetByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_MacroGetByID]
GO


CREATE PROCEDURE dbo.Admin_MacroGetByID
(
  @MacroID int
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Select		mal.MetroAreaName As metroname
			,mn.metroareaid As metroID
			,mn.MacroName As macroname
			,mn.Active
			,SortOrder as sort_order
			,(Select count(LanguageID) from MacroNeighborhoodAVW where MacroID = @MacroID) as Languages
			,ma.OpLanguageId as PrimaryLanguageID
From		MacroNeighborhoodVW mn 
inner join	MetroAreaLocal mal 
on			mal.metroareaid = mn.metroareaid
and			mal.LanguageID = mn.LanguageID
inner join	MetroArea ma
on			ma.metroareaid = mn.metroareaid
Where		MacroID = @MacroID

GO

GRANT EXECUTE ON [Admin_MacroGetByID] TO ExecuteOnlyRole

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_MacroInfo_Get]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_MacroInfo_Get]
GO


CREATE PROCEDURE dbo.Admin_MacroInfo_Get
(
  @MacroID int
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Select		m.MetroAreaName As metroname
			,mn.metroareaid As metroID
			,mn.MacroName As macroname
			,mn.Active
			,SortOrder as sort_order
			,mn.LanguageID
			,PrimaryLanguageID
From		MacroNeighborhoodAVW mn 
inner join	MetroAreaAVW m
on			m.metroareaid = mn.metroareaid
and			m.LanguageID = mn.LanguageID
Where		MacroID = @MacroID

GO

GRANT EXECUTE ON [Admin_MacroInfo_Get] TO ExecuteOnlyRole

GO

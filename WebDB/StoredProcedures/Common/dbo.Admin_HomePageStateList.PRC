
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_HomePageStateList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_HomePageStateList]
GO


CREATE PROCEDURE dbo.Admin_HomePageStateList (@StateID as nchar(2))

As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Select		sn.StateName, 
		sl.MacroID, 
		sl.MetroAreaID, 
		coalesce(ShortName,macroName, MetroAreaName) as FeaturedName, 
		sl.AreaSection, 		
		sn.StateID,
		sl.AreaID,
		sl.IsFeatured,
		sl.DomainID
from		StateName sn
inner join	StateAreaListing sl
on		sn.StateID = sl.StateID 
and		active = 1
inner join	MetroareaVW ma
on		sl.MetroAreaID = ma.MetroAreaID
left join	macroneighborhoodVW mn
on		mn.MacroID = sl.MacroID
where		HomePage = 1
and		sn.StateID = @StateID
order by	sl.IsFeatured desc, sl.AreaSection asc, FeaturedName asc
GO

GRANT EXECUTE ON [Admin_HomePageStateList] TO ExecuteOnlyRole

GO

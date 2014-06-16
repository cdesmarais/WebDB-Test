
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheHPStateList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheHPStateList]
GO


CREATE PROCEDURE dbo.DNCacheHPStateList
 As

SET NOCOUNT ON
set transaction isolation level read uncommitted

Select		StateName, 
			StateAreaListing.MacroID, 
			StateAreaListing.MetroAreaID, 
			coalesce(ShortName,macroName, MetroAreaName) as FeaturedName, 
			AreaSection, 
			(select count(StateID) from StateAreaListing where StateID = sn.StateID) as dropcount, 
			sn.StateID
from		StateName sn
left join	StateAreaListing 
on			sn.StateID = StateAreaListing.StateID 
and			active = 1
left join	MetroareaVW ma
on			StateAreaListing.MetroAreaID = ma.MetroAreaID
left join	macroneighborhoodVW mn
on			mn.MacroID = StateAreaListing.MacroID
where		HomePage = 1
order by	StateName, AreaSection, FeaturedName
GO

GRANT EXECUTE ON [DNCacheHPStateList] TO ExecuteOnlyRole

GO

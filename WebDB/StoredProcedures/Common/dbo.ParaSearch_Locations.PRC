if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ParaSearch_Locations]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ParaSearch_Locations]
GO

CREATE Procedure dbo.ParaSearch_Locations
 (
  @restaurants varchar(8000) --[EV: List of Int IDs]
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

Select n.neighborhoodid as NeighborhoodID,n.NbhoodName as NeighborhoodName,n.MacroID as Macro_ID,MacroName as Macro_Name
from RestaurantVW r
inner join	NeighborhoodAVW n 
on			n.neighborhoodid = r.neighborhoodid
and			n.LanguageID = r.LanguageID
inner join	MacroNeighborhoodAVW mn
on			n.MacroID = mn.MacroID
and			mn.LanguageID = r.LanguageID
where CHARINDEX(',' + cast(RID as varchar(10)) + ',',',' + @restaurants + ',') > 0
order by MacroName,n.NbhoodName

GO

GRANT EXECUTE ON [ParaSearch_Locations] TO ExecuteOnlyRole

GO

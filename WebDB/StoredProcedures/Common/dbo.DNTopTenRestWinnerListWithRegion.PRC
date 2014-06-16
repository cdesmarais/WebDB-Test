if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNTopTenRestWinnerListWithRegion]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNTopTenRestWinnerListWithRegion]
GO

CREATE PROCEDURE dbo.DNTopTenRestWinnerListWithRegion

AS

set transaction isolation level read uncommitted

select 
	ttli.TopTenListInstanceID,
	ttlr.RID,
	coalesce( ttl.listnameoverride, ttlt.listname ) toptenlistname,
	CASE WHEN (ttl.MacroID IS NULL OR ttl.TopTenListTypeID = 22) THEN 0 ELSE 1 END AS IsRegionalList,
	mn.MacroName,
	m.MetroAreaName,
	ttl.TopTenListTypeID
from TopTenListRestaurant ttlr
inner join RestaurantVW r
	on   ttlr.RID      = r.RID
inner join NeighborhoodVW n
	on   n.NeighborhoodID    = r.NeighborhoodID
inner join MacroNeighborhoodVW    mn
	on   mn.MacroID      = n.MacroID
inner join dbo.MetroAreaVW m
	ON mn.MetroAreaID = m.MetroAreaID
inner join TopTenListInstance ttli
	on ttli.TopTenListInstanceID = ttlr.TopTenListInstanceID
inner join TopTenListVW ttl
	on ttl.TopTenListID = ttli.TopTenListID
inner join TopTenListType ttlt
	on ttlt.TopTenListTypeID = ttl.TopTenListTypeID
inner join TopTenImportJob     ttij
	on ttij.TopTenImportJobID = ttli.TopTenImportJobID  
left join TopTenListRestaurantSuppression ttlrs
	on ttlrs.TopTenListID = ttl.TopTenListID
	and ttlrs.RID = ttlr.RID  
where ttli.isActive = 1
	and coalesce(ttij.Status,1) = 1  
	and mn.Active = 1  
	and ttlrs.RID is null
	and ttlr.Rank <= 10
order by ttlr.RID, IsRegionalList DESC, toptenlistname

GO

GRANT EXECUTE ON [DNTopTenRestWinnerListWithRegion] TO ExecuteOnlyRole

GO

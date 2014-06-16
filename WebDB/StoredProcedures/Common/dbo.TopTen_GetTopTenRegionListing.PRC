if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTen_GetTopTenRegionListing]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].TopTen_GetTopTenRegionListing

GO

CREATE PROCEDURE dbo.TopTen_GetTopTenRegionListing
(
	@MacroneighborhoodID int
)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


Select			ttl1.toptenListID, 
		        ttl1.topTenListTypeID,
		        coalesce(ttl1.ListNameOverRide,  ttlt.ListName) as ListName, 
		        ttl1.MetroAreaID, 
		        ttl1.MacroID, 
		        ttl2.ListDisplayOrder,
		        ttltc.TopTenListTypeClassName,
		        ISNULL(ttli.IsActive, 0) as IsActive
from 			TopTenList ttl1
inner join		TopTenList ttl2 on ttl1.TopTenListTypeID = ttl2.TopTenListTypeID
and				ttl1.MetroAreaID = ttl2.MetroAreaID
and				ttl2.MacroID is null
inner join 		TopTenListType ttlt ON ttl1.TopTenListTypeID = ttlt.TopTenListTypeID
inner join 		TopTenListTypeClass ttltc on ttlt.TopTenListTypeClassID = ttltc.TopTenListTypeClassID
left join 		TopTenListInstance ttlI ON ttl1.TopTenListID = ttli.TopTenListID
left join 		TopTenImportJob ttIJ ON ttlI.TopTenImportJobID = ttij.TopTenImportJobID 
where			ttl1.MacroID = @MacroneighborhoodID
and	  			(ttij.status = 1 or ttli.toptenlistinstanceid is null)
and  			ttl1.TopTenListTypeID != 22
order by 		ttl2.ListDisplayOrder

GO

GRANT EXECUTE ON [TopTen_GetTopTenRegionListing] TO ExecuteOnlyRole

GO


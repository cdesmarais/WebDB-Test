if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTen_GetTopTenMetroListing]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].TopTen_GetTopTenMetroListing

GO

CREATE PROCEDURE dbo.TopTen_GetTopTenMetroListing
(
	@MetroAreaID int
)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Declare @ActiveJobID int

SELECT	@ActiveJobID = ttij.TopTenImportJobID
FROM	TopTenImportJob ttij
WHERE	ttij.Status = 1

select 		ttl.toptenListID, 
			ttl.topTenListTypeID,
			coalesce(ttl.ListNameOverRide,  ttlt.ListName) as ListName, 
			ttl.MetroAreaID, 
			ttl.MacroID, 
			ttl.ListDisplayOrder,
			ttltc.TopTenListTypeClassName,
			isnull(ttlI.IsActive, 0) as IsActive
from 		TopTenList ttl
inner join 	TopTenListType ttlt ON ttl.TopTenListTypeID = ttlt.TopTenListTypeID
inner join 	TopTenListTypeClass ttltc on ttlt.TopTenListTypeClassID = ttltc.TopTenListTypeClassID
left join 	TopTenListInstance ttli ON ttl.TopTenListID = ttli.TopTenListID
and 		ttli.TopTenImportJobID = @ActiveJobID --Active job id
where 		ttl.MetroAreaId = @MetroAreaID
and	  		(ttl.MacroID is null OR ttl.topTenListTypeID = 22)
order by 	ttl.ListDisplayOrder

GO

GRANT EXECUTE ON [TopTen_GetTopTenMetroListing] TO ExecuteOnlyRole

GO


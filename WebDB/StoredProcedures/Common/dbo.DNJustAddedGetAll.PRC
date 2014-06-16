if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNJustAddedGetAll]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNJustAddedGetAll]
GO

CREATE PROCEDURE dbo.DNJustAddedGetAll

AS

set transaction isolation level read uncommitted

Select		r.RName as Name
			,r.RID as Restaurant_ID
			,n.NbhoodName as NeighborName
			,mn.MacroID as MacroID
			,mn.MacroName as [MacroName]
			,mn.SortOrder as [SortOrder]
			, n.metroareaid as [metroareaid]
			,(Case when(r.PriceQuartileID=5) then 0 else r.PriceQuartileID end) AS PriceQuartileID
			, ft.FoodType AS FoodType
			, ft.FoodTypeID as FoodTypeID
			, r.RSName
			,(CASE WHEN LEFT(r.RSName, 4) = 'The ' THEN SUBSTRING(r.RSName, 5, Len(r.RSName)-4) ELSE r.RSNAME END) As [RSNameSort]
			,(CASE WHEN LEFT(r.RName, 4) = 'The ' THEN SUBSTRING(r.RName, 5, Len(r.RName)-4) ELSE r.RNAME END) As [RNameSort]
from		RestaurantVW r
inner join	NeighborhoodAVW n 
on			n.neighborhoodid = r.neighborhoodid
and			n.LanguageID = r.LanguageID
inner join	MacroNeighborhoodAVW mn
on			mn.MacroID = n.MacroID
and			mn.LanguageID = r.LanguageID
inner join	RestaurantJustAdded rja
on			r.RID = rja.RID
inner join	FoodTypes fts
ON			r.RID = fts.RID 
AND			isPrimary = 1
inner join	FoodType ft
ON			fts.FoodTypeID = ft.FoodTypeID 
and			ft.LanguageID = r.LanguageID
where		JustAdded = 1
and			reststateID in (1,13,5,6,7,16)
order by	[metroareaid]
			,[SortOrder]
			,[MacroName]
			,[RSNameSort] 
			,[RNameSort] 
GO

GRANT EXECUTE ON [DNJustAddedGetAll] TO ExecuteOnlyRole

GO

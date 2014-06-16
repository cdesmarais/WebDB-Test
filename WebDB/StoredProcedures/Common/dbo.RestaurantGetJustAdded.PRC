if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantGetJustAdded]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantGetJustAdded]
GO

CREATE PROCEDURE dbo.RestaurantGetJustAdded

AS

set transaction isolation level read uncommitted

Select 
			 r.RName as Name
			,r.RID as Restaurant_ID
			,n.NbhoodName as NeighborName
			,mn.MacroName as MacroName
			,n.metroareaid
from		 RestaurantVW r
inner join	 NeighborhoodAVW n 
on			 n.neighborhoodid = r.neighborhoodid
and			 n.LanguageID = r.LanguageID
inner join	 MacroNeighborhoodAVW mn
on			 mn.MacroID = n.MacroID
and			 mn.LanguageID = r.LanguageID
inner join	 RestaurantJustAdded 
on			 r.RID = RestaurantJustAdded.RID
where		 JustAdded = 1
order by	 SortOrder
			,r.RName

GO

GRANT EXECUTE ON [RestaurantGetJustAdded] TO ExecuteOnlyRole

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Restaurant_Comingsoon]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Restaurant_Comingsoon]
GO

CREATE PROCEDURE dbo.Report_Restaurant_Comingsoon

AS

set transaction isolation level read uncommitted

select		r.RID
			,r.RName 'RestaurantName'
			,ma.MetroAreaID
			,ma.MetroAreaName 'MetroAreaName'
			,rs.RState 'RestaurantStatus'
from		RestaurantVW r
inner join	Neighborhood n 
on			r.NeighborhoodID = n.NeighborhoodID
inner join	MetroAreaAVW ma 
on			n.MetroAreaID = ma.MetroAreaID
and			r.LanguageID = ma.LanguageID
inner join	RestaurantState rs 
on			r.RestStateID = rs.RestStateID
where		r.RestStateID in (2,3,5,8)
and			ma.MetroAreaID not in(1)
order by	ma.MetroAreaID
			,r.RName


GO


GRANT EXECUTE ON [Report_Restaurant_Comingsoon] TO ExecuteOnlyRole

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_NewRestaurants]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_NewRestaurants]
GO

CREATE PROCEDURE dbo.Report_NewRestaurants
AS

set transaction isolation level read uncommitted

select r.RID as restaurant_ID
	,r.RName
	,r.CreateDate as create_Date
	,rs.RState
	,ma.MetroAreaID as metro_area_ID
	,ma.MetroAreaName
from		RestaurantVW r
inner join	RestaurantState rs 
on			r.RestStateID = rs.RestStateID
inner join	NeighborhoodAVW n 
on			r.NeighborhoodID = n.NeighborhoodID
and			r.LanguageID = n.LanguageID
inner join	MetroAreaAVW ma 
on			n.MetroAreaID = ma.MetroAreaID
and			r.LanguageID = ma.LanguageID
where		datediff(month, r.CreateDate, getdate()) = 1
and			ma.MetroAreaID <> 1

GO


GRANT EXECUTE ON [Report_NewRestaurants] TO ExecuteOnlyRole

GO

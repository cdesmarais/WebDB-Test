
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobReportRestaurantsWithProfileImage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobReportRestaurantsWithProfileImage]
GO

create Procedure [dbo].[JobReportRestaurantsWithProfileImage] 
As

set nocount on
set transaction isolation level read uncommitted

select		r.RName
			,r.RID
			,metro.MetroAreaName
			,metro.CountryID
			,case when coalesce(ri.ImageName,0) = 0 then 'N' else 'Y' end 'Has Profile Image'
			,rs.RState 'Restaurant Status'
from		RestaurantVW r
left join	RestaurantImage ri
on			ri.RID = r.RID
inner join	Neighborhood neig
on			r.NeighborhoodID = neig.NeighborhoodID
inner join	MetroAreaVW metro
on			neig.MetroAreaID = metro.MetroAreaID
inner join	RestaurantState rs
on			r.RestStateID = rs.RestStateID
where		r.RestStateID in (1, 13, 7, 16, 8, 9)
and			metro.CountryID in ('US', 'MX', 'CA', 'UK', 'DE')
order by	metro.MetroAreaName
			,r.RName
			
GO

GRANT EXECUTE ON [dbo].[JobReportRestaurantsWithProfileImage] TO DTR_User

GO
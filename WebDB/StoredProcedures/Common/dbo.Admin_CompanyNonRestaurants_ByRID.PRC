
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_CompanyNonRestaurants_ByRID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_CompanyNonRestaurants_ByRID]
go


create proc [dbo].[Admin_CompanyNonRestaurants_ByRID]
(
	@restaurantidkey		int	
	,@HotelID				int
)
as

	set transaction isolation level read uncommitted

	select 		r.RID				'RID'
				,r.RName			'Restaurant Name'
				,m.metroareaname	'Metro'
				,r.Address1	
				+ ', ' + r.City 
				+ ', ' + r.State 
				+ ', ' + r.Zip		'Address'					
				, case	when r.RID in (select	RID 
								from	CompanyNonRestaurants 
								where	HotelID = @HotelID) 
						then	1
						else	0 
						end				'Selected'
	from		RestaurantVW r    
	inner join	Neighborhood n 
	on			r.neighborhoodid = n.neighborhoodid 	
	inner join	MetroAreaLocal m 
	on			n.metroareaid = m.metroareaid 
	and			r.languageid = m.languageid  
	where		r.RID = @restaurantidkey		
	
	GO
	
GRANT EXECUTE ON [Admin_CompanyNonRestaurants_ByRID] TO ExecuteOnlyRole

GO




if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_CompanyNonRestaurants_ByName]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_CompanyNonRestaurants_ByName]
go


create proc [dbo].[Admin_CompanyNonRestaurants_ByName]
(
	@keywords       nvarchar(50)
	,@HotelID		int	
)
as

	set transaction isolation level read uncommitted

	select		r.RID				'RID'
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
	from		dbo.RestaurantVW r
	inner join	Neighborhood n  
	on			r.neighborhoodid = n.neighborhoodid  
	inner join	MetroAreaLocal m  
	on			n.metroareaid = m.metroareaid  
	and			r.languageid = m.languageid 	
	where		r.RName like '%' + @keywords + '%'	
	order by	r.RName
	
go
	
GRANT EXECUTE ON [Admin_CompanyNonRestaurants_ByName] TO ExecuteOnlyRole

GO




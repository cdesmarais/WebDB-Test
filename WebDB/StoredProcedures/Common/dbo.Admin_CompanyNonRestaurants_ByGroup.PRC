if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_CompanyNonRestaurants_ByGroup]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_CompanyNonRestaurants_ByGroup]
go


create proc [dbo].[Admin_CompanyNonRestaurants_ByGroup]
(
	@groupname      nvarchar(50)
	,@HotelID		int
)
as

	set transaction isolation level read uncommitted

	select	r.RID				'RID'
			,r.RName			'Restaurant Name'
			,m.metroareaname	'Metro'
			,r.Address1	
			+ ', ' + r.City 
			+ ', ' + r.State 
			+ ', ' + r.Zip		'Address'	
			,(case  when co.RID is null then 0
                    else       1
					end        
			 )					'Selected'
	from		RestaurantVW r
	inner join	RestaurantToGroup rtg 
	on			r.RID = rtg.RID 
	inner join	RestaurantGroup g 
	on			rtg.GID = g.GID
	inner join	Neighborhood n 
	on			r.neighborhoodid = n.neighborhoodid    
	inner join	MetroAreaLocal m 
	on			n.metroareaid = m.metroareaid 
	and			r.languageid = m.languageid    
	left join	CompanyNonRestaurants co
	on			r.RID = co.RID
	and			co.HotelID = @HotelID 
	where		g.Groupname = @groupname 
	order by	r.RName

go

GRANT EXECUTE ON [Admin_CompanyNonRestaurants_ByGroup] TO ExecuteOnlyRole

GO

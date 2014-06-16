if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNListExcludedRestaurants]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNListExcludedRestaurants]
GO

CREATE PROCEDURE dbo.DNListExcludedRestaurants @HotelID int, @CompanyName nvarchar(60)

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

if (@HotelID > 0)
begin	
	select		distinct 
				r.rid  
				,r.rname  
				,m.metroareaname
				,(	select Max(DateChanged)
					from LogCompanyNonRestaurants 
					where HotelID = cn.HotelID and RID = r.RID
                    and Action = 'Add'
					group by RID, HotelID
				) as DateChanged	
				,(	select Max(UserName)
					from LogCompanyNonRestaurants 
					where HotelID = cn.HotelID and RID = r.RID
                    and Action = 'Add'
					group by RID, HotelID
				) as UserName
	from		RestaurantVW r  
	inner join	CompanyNonrestaurants cn
	on			r.RID = cn.RID	
	inner join	Neighborhood n  
	on			r.neighborhoodid = n.neighborhoodid  
	inner join	MetroAreaLocal m  
	on			n.metroareaid = m.metroareaid  
	and			r.LanguageID = m.LanguageID  	
	where		cn.HotelID = @HotelID		
	order by	m.metroareaname, r.rname
end


else if (@CompanyName is not null)
begin
	select		distinct 
				r.rid  
				,r.rname  
				,m.metroareaname
				,(	select Max(DateChanged)
					from LogCompanyNonRestaurants 
					where HotelID = cn.HotelID and RID = r.RID
                    and Action = 'Add'
					group by RID, HotelID
				) as DateChanged	
				,(	select Max(UserName)
					from LogCompanyNonRestaurants 
					where HotelID = cn.HotelID and RID = r.RID
                    and Action = 'Add'
					group by RID, HotelID
				) as UserName
	from		RestaurantVW r  
	inner join	CompanyNonrestaurants cn
	on			r.RID = cn.RID	
	inner join	Company co
	on			co.CompanyID = cn.HotelID
	inner join	Neighborhood n  
	on			r.neighborhoodid = n.neighborhoodid  
	inner join	MetroAreaLocal m  
	on			n.metroareaid = m.metroareaid  
	and			r.LanguageID = m.LanguageID  	
	where		co.CompanyName = @CompanyName	
	order by	m.metroareaname, r.rname
end

GO

GRANT EXECUTE ON [DNListExcludedRestaurants] TO ExecuteOnlyRole

GO

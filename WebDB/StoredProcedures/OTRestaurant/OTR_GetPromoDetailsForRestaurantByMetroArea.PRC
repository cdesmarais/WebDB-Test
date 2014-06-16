/* stored procedure to get the promo details for restaurant for a metro area name */
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTR_GetPromoDetailsForRestaurantByMetroArea]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTR_GetPromoDetailsForRestaurantByMetroArea]
GO

create procedure dbo.[OTR_GetPromoDetailsForRestaurantByMetroArea]
(          
  @MetroArea nvarchar(255),            
  @RID int,                
  @PromoID int                
)                
as          
declare @MetroAreaID int          
select @MetroAreaID = 0          
          
Begin          
          
	set @MetroAreaID = (select m.[MetroAreaID] from  [RestaurantVW] r          
	         
					  inner join NeighborhoodVW n on          
					  n.NeighborhoodID = r.NeighborhoodID          
				               
					  inner join MetroAreaVW m on          
					  m.MetroAreaID  = n.MetroAreaID          
				             
					 where           
					  r.[RID] = @RID)    
          
	Exec AdminPromosPagesGetRests @MetroAreaID, @PromoID, @RID  

End 

GO

grant execute on [OTR_GetPromoDetailsForRestaurantByMetroArea] TO ExecuteOnlyRole

GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminPromosPagesGetRestsAll1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminPromosPagesGetRestsAll1]
GO

  

CREATE PROCEDURE dbo.AdminPromosPagesGetRestsAll1    
(    
  @MetroArea int,    
  @PromoID int    
)    
AS    
SET NOCOUNT ON    
SET TRANSACTION ISOLATION LEVEL READ COMMITTED    
    
Select  r.RID as Restaurant_ID    
   ,r.Rname as restname    
   ,ma.MetroAreaName as metroarea    
   ,COALESCE(PromoRests.PromoID,0) as promo    
   ,COALESCE(PromoRests.Message,'') as promo_message    
   ,n.NbhoodName as neighborhood_name    
   ,COALESCE(Rank,999) as Rank    
   ,lunch    
   ,dinner    
   ,r.RestStateID AS RestaurantState    
   ,COALESCE(PromoPagesToMetro.MetroID,0) as MetroID    
   ,COALESCE(PDE.SupressDIPLunch,PP.SuppressDIP) as SupressDIPLunch    
   ,COALESCE(PDE.SupressDIPDinner,PP.SuppressDIP) as SupressDIPDinner    
   ,PP.SuppressDIP    
   ,r.RSName    
   ,ma.SupportedDomainID    
from  RestaurantVW r    
left join PromoRests     
on   r.RID = PromoRests.RID     
and   PromoRests.PromoID = @PromoID    
inner join NeighborhoodAVW n     
on   n.neighborhoodid = r.neighborhoodid    
and   n.LanguageID = r.LanguageID    
inner Join MetroAreaAVW ma    
on   ma.metroareaid = n.metroareaid    
and   ma.LanguageID = r.LanguageID    
left outer join PromoPagesToMetro     
on   n.metroareaid  = PromoPagesToMetro.MetroID     
and   PromoPagesToMetro.PromoID = @PromoID      
and   PromoPagesToMetro.MetroID = @MetroArea    
LEFT JOIN  PromoDIPSupressExclusion PDE    
ON   (r.RID = PDE.RID and PDE.PromoID=@PromoID)    
LEFT JOIN PromoPages PP    
ON   (PP.PromoID = @PromoID)    
LEFT JOIN PromoPagesToPromoGroups PP2PG    
ON   PP.PromoID = PP2PG.PromoID 
and PP2PG.PromoGroupTypeID =1 -- checking for Rest Week Promo Group (whose ID is 1)
LEFT JOIN BlackListPromoWeekRestaurants blackListRIDS  
ON   (r.RID = blackListRIDS.RID)  
where  ma.metroareaid = @MetroArea     
and   r.RestStateID not in (2,3,4,8)     
and   ((blackListRIDS.RID is null)     
      or   
	  (coalesce(PP2PG.Active,0)=0))    
order by     
            rank     
            ,r.RSName    
            ,case when ( charindex('The ',ltrim(r.Rname)) = 1 ) then  -- while sorting do not consider 'The ' in beginning of restaurant name    
                ltrim(replace(r.Rname, 'The ',''))  -- left trim restaurant name     
             else       
                ltrim(r.Rname)      
             end       
         
GO

GRANT EXECUTE ON [AdminPromosPagesGetRestsAll1] TO ExecuteOnlyRole

GO


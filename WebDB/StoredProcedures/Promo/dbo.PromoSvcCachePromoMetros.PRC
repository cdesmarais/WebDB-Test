if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PromoSvcCachePromoMetros]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].PromoSvcCachePromoMetros
GO

create procedure dbo.PromoSvcCachePromoMetros
as
set nocount on
set transaction isolation level read uncommitted

SELECT 
    dbo.fGetRegionID() AS RegionID
    ,PromoID
    ,MetroID
    ,ma.TZID AS MetroTzid
    ,OnStartPage
    ,OnContent
    ,NoFollow
FROM PromoPagesToMetro
INNER JOIN MetroArea ma  
    ON  ma.MetroAreaID = MetroID  
        AND ma.Active = 1 

UNION

SELECT
    dbo.fGetRegionID() AS RegionID
    ,p.PromoID 
    ,ma.MetroAreaID AS MetroID
    ,ma.TZID AS MetroTzid
    ,null AS OnStartPage  
    ,null AS OnContent  
    ,null AS NoFollow
FROM  PromoPages p  
INNER JOIN PromoRests pr  
    ON  p.PromoID = pr.PromoID 
        AND p.Active = 1  
INNER JOIN Restaurant r  
    ON  pr.RID = r.RID  
        AND r.RestStateID <> 17 -- not TT migrated
INNER JOIN Neighborhood n   
    ON  n.NeighborhoodID = r.NeighborhoodID  
        AND n.Active = 1
INNER JOIN MetroArea ma  
    ON  ma.MetroAreaID = n.MetroAreaID  
        AND ma.Active = 1 
LEFT JOIN PromoPagesToMetro pptm  
    ON  pptm.PromoID = p.PromoID 
        AND pptm.MetroID = ma.MetroAreaID
WHERE pptm.PromoID IS null

go


grant execute on PromoSvcCachePromoMetros to ExecuteOnlyRole

GO


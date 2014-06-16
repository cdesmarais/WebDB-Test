if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheStateMetroList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheStateMetroList]
GO



CREATE PROCEDURE dbo.DNCacheStateMetroList
 As

SET NOCOUNT ON


select distinct state, statename, metroareaname, m.metroareaid, pl.PromoLinkURL AS LimoURL  
from restaurantvw r
inner join neighborhood n on n.neighborhoodid = r.neighborhoodid
inner join metroareavw m on m.metroareaid = n.metroareaid
inner join statename s on r.state = s.stateid
LEFT outer JOIN dbo.PromoLinkToID plid on m.metroAreaID = plid.valueID    
LEFT OUTER JOIN dbo.promolink pl on pl.promolinkid = plid.promolinkid    
AND pl.promolinktypeid = 1     -- 1: Limo 
where country = 'US' and r.state <> '' and r.reststateid = 1 and m.active = 1 
and m.metroareaid <> 1 and m.metroareaid <> 58

GO

GRANT EXECUTE ON [DNCacheStateMetroList] TO ExecuteOnlyRole

GO



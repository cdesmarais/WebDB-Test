if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminPromosPagesGetMetrosByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminPromosPagesGetMetrosByID]
GO



CREATE PROCEDURE dbo.AdminPromosPagesGetMetrosByID
(
  @PromoID int
)
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- Get Domain ID separately so as not to break left outer join below.
Declare @SupportedDomainID AS int
Select @SupportedDomainID = SupportedDomainID 
from PromoPages where PromoID = @PromoID

Select 
ma.metroAreaID
, MetroAreaName
, PromoPagesToMetro.metroID
, active 
from metroAreaVW ma
left outer join PromoPagesToMetro 
on ma.MetroAreaID = PromoPagesToMetro.metroID 
and promoid = @PromoID
and OnStartPage = 1
where (active = 1 and SupportedDomainID = @SupportedDomainID)
or metroareaID = 1
order by MetroAreaName



GO

GRANT EXECUTE ON [AdminPromosPagesGetMetrosByID] TO ExecuteOnlyRole

GO
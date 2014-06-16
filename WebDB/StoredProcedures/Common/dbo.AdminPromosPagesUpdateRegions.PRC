
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminPromosPagesUpdateRegions]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminPromosPagesUpdateRegions]
GO






CREATE PROCEDURE dbo.AdminPromosPagesUpdateRegions
(
  @PromoID int
)
AS
SET NOCOUNT ON



BEGIN TRANSACTION

Delete from PromoPagesToRegion where PromoID =  @PromoID

Insert into PromoPagesToRegion
( PromoID, RegionID )
Select distinct @PromoID as PromoID, MacroID as RegionID from PromoRests 
inner join restaurant on PromoRests.rid = restaurant.rid
inner join neighborhood on restaurant.neighborhoodid = neighborhood.neighborhoodid
where promoID = @PromoID


if @@ERROR <> 0
		goto error

COMMIT TRANSACTION
Return(0)
 
error:
ROLLBACK TRANSACTION
Return(0)
GO


GRANT  EXECUTE  ON [dbo].[AdminPromosPagesUpdateRegions]  TO [ExecuteOnlyRole]
GO


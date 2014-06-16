if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminPromosPagesDeactivateAllMetro]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminPromosPagesDeactivateAllMetro]
GO



CREATE PROCEDURE dbo.AdminPromosPagesDeactivateAllMetro
(
  @PromoID int
)
AS
SET NOCOUNT ON
BEGIN TRANSACTION

Delete from PromoPagesToMetro where PromoID =  @PromoID

if @@ERROR <> 0
		goto error

COMMIT TRANSACTION
Return(0)
 
error:
ROLLBACK TRANSACTION
Return(0)


GO

GRANT EXECUTE ON [AdminPromosPagesDeactivateAllMetro] TO ExecuteOnlyRole

GO

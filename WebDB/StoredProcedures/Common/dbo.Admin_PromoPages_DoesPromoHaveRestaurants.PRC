

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_PromoPages_DoesPromoHaveRestaurants]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_PromoPages_DoesPromoHaveRestaurants]
GO

/****** Object:  StoredProcedure [dbo].[Admin_PromoPages_DoesPromoHaveRestaurants]    Script Date: 07/30/2012 15:03:18 ******/

CREATE PROCEDURE [dbo].[Admin_PromoPages_DoesPromoHaveRestaurants]
(
  @PromoID int,
  @HasAssociatedRestaurants int out
)
AS
SET NOCOUNT ON

Set @HasAssociatedRestaurants  =0

IF EXISTS (Select RID From PromoRests where PromoID=@PromoID)
BEGIN
Set @HasAssociatedRestaurants =1
END

if @@ERROR <> 0
		goto error
Return(0)
 
error:
Return(0)

GO

GRANT  EXECUTE  ON [dbo].[Admin_PromoPages_DoesPromoHaveRestaurants]  TO [ExecuteOnlyRole]
GO


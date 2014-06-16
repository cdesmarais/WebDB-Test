if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Promos_Activation]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Promos_Activation]
GO




CREATE PROCEDURE dbo.Admin_Promos_Activation
 (
  @Promo_ID int,
  @Active bit
 )
As
SET NOCOUNT ON
UPDATE Promos
SET active = @Active
WHERE PromoID =  @Promo_ID
GO

GRANT EXECUTE ON [Admin_Promos_Activation] TO ExecuteOnlyRole

GO

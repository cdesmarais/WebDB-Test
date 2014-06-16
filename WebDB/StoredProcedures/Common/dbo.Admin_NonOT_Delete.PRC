if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_NonOT_Delete]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_NonOT_Delete]
GO


CREATE PROCEDURE dbo.Admin_NonOT_Delete
(
  @metro_ID int,
  @promo_ID int
)
AS

SET TRAN ISOLATION LEVEL SERIALIZABLE

Delete from PromoNonOTRestaurants where MetroID = @metro_ID and PromoID = @promo_ID
GO

GRANT EXECUTE ON [Admin_NonOT_Delete] TO ExecuteOnlyRole

GO

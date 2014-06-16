if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Offers_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Offers_Update]
GO




/****** Object:  Stored Procedure dbo.Admin_Offers_Update    Script Date: 2/7/2000 3:55:32 PM ******/
CREATE PROCEDURE dbo.Admin_Offers_Update
 (
  @RestaurantID int,
  @OfferID int
 )
As
SET NOCOUNT ON
EXECUTE Admin_Offers_Delete @RestaurantID
EXECUTE Admin_Offers_Add @RestaurantID,@OfferID




GO

GRANT EXECUTE ON [Admin_Offers_Update] TO ExecuteOnlyRole

GO

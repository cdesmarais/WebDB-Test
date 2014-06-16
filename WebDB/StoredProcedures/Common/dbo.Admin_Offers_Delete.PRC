if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Offers_Delete]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Offers_Delete]
GO


CREATE Procedure dbo.Admin_Offers_Delete
 (
  @RestaurantID int
 )
As
SET NOCOUNT ON
DELETE FROM Offers
WHERE (RID = @RestaurantID)
GO

GRANT EXECUTE ON [Admin_Offers_Delete] TO ExecuteOnlyRole

GO

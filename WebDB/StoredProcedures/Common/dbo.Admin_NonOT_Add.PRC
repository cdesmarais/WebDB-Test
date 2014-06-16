if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_NonOT_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_NonOT_Add]
GO


CREATE PROCEDURE dbo.Admin_NonOT_Add
(
  @metro_ID int,
  @promo_ID int,
  @RestName nvarchar(255),
  @Phone nvarchar(50),
  @Address nvarchar(50),
  @City nvarchar(50)
)
AS

SET TRAN ISOLATION LEVEL SERIALIZABLE

Insert into PromoNonOTRestaurants 
(
RestaurantName,
Phone,
MetroID,
PromoID,
Address,
City
) 
VALUES 
(
@RestName,
@Phone,
@metro_ID,
@promo_ID,
@Address,
@City
)
GO

GRANT EXECUTE ON [Admin_NonOT_Add] TO ExecuteOnlyRole

GO

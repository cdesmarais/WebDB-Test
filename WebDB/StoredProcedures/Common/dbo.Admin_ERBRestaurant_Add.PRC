if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ERBRestaurant_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ERBRestaurant_Add]
GO


CREATE Procedure DBO.Admin_ERBRestaurant_Add
 (
  @RestaurantID int,
  @ServerIP nvarchar(255),
  @ServerPassword nvarchar(255),
  @ServerKey nvarchar(255),
  @ProductType int
  , @StaticIPAddress int
 )
As
SET NOCOUNT ON
INSERT INTO ERBRestaurant
 (
  RID,
  ServerIP,
  serverPwd,
  ServerKey,
  ProductID
,  StaticIPAddress
 )
VALUES
 (
  @RestaurantID,
  @ServerIP,
  @ServerPassword,
  @ServerKey,
  @ProductType
, @StaticIPAddress
 )
GO

GRANT EXECUTE ON [Admin_ERBRestaurant_Add] TO ExecuteOnlyRole

GO

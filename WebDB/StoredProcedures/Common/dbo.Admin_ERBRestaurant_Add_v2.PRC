if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ERBRestaurant_Add_v2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ERBRestaurant_Add_v2]
GO


CREATE Procedure DBO.Admin_ERBRestaurant_Add_v2
 (
   @RestaurantID int
  ,@ServerIP nvarchar(255)
  ,@ServerPassword nvarchar(255)
  ,@ServerKey nvarchar(255)
  ,@ProductType int
  ,@StaticIPAddress int
  ,@Allotment bit
 )
As
SET NOCOUNT ON

declare @ConsoleRestaurantVersion varchar(50)
set @ConsoleRestaurantVersion = '1.0.0.1000'

INSERT INTO ERBRestaurant
 (
   RID
  ,ServerIP
  ,serverPwd
  ,ServerKey
  ,ProductID
  ,StaticIPAddress
  ,ERBVersion
  ,ListenerVersion
  ,CacheServerERBGroupID
 )
VALUES
 (
   @RestaurantID
  ,@ServerIP
  ,@ServerPassword
  ,@ServerKey
  ,@ProductType
  ,@StaticIPAddress
  ,case WHEN @Allotment = 1 THEN @ConsoleRestaurantVersion ELSE null end
  ,case WHEN @Allotment = 1 THEN @ConsoleRestaurantVersion ELSE null end
  ,dbo.fGetBestCSGroupForNewERB()
 )
GO

GRANT EXECUTE ON [Admin_ERBRestaurant_Add_v2] TO ExecuteOnlyRole

GO

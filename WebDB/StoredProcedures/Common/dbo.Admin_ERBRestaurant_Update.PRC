if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ERBRestaurant_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ERBRestaurant_Update]
GO
 
create procedure dbo.Admin_ERBRestaurant_Update  
 (  
  @RestaurantID int,  
  @ServerIP nvarchar(255),  
  @ServerPassword nvarchar(255),  
  @ServerKey nvarchar(255),  
  @ProductType int,
  @StaticIPAddress int,
  @RestaurantStateID int
 )  
As  
  
SET NOCOUNT ON  
declare @InitiatingUninstallRestState int

-- not querying because this value never changes
set @InitiatingUninstallRestState=8 
	
-- check Is Restaurant status is "Initiating Uninstall (8)"  
if @RestaurantStateID <> @InitiatingUninstallRestState
	begin
		-- update Restaurant ERB information and update ERBLockFromROMS flag to 0
		-- if user change the Restaurant status to any other than "Iniating Uninstall"
		update
			ERBRestaurant  
		set  
			ServerIP=@ServerIP,  
			serverPwd=@ServerPassword,  
			ServerKey=@ServerKey,  
			ProductID = @ProductType,  
			StaticIPAddress = @StaticIPAddress,
			ERBLockFromROMS = 0
		where 
			(RID = @RestaurantID)  
	end
else
	begin
		-- update Restaurant ERB information.
		update 
			ERBRestaurant  
		set  
			ServerIP=@ServerIP,  
			serverPwd=@ServerPassword,  
			ServerKey=@ServerKey,  
			ProductID = @ProductType,  
			StaticIPAddress = @StaticIPAddress
		where 
			(RID = @RestaurantID) 
	end
  

GO

GRANT EXECUTE ON [Admin_ERBRestaurant_Update] TO ExecuteOnlyRole
GO


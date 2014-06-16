
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_UpdateServerInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_UpdateServerInfo]
GO


create procedure [dbo].[Admin_Restaurant_UpdateServerInfo]
(
	@RestaurantID int
	,@ServerIPAddress nvarchar(255)
	,@ServerPass nvarchar(255)
	,@StaticIP int
	,@RestaurantStateID int
	,@IsOptOutForFRNandBackSoon bit
 )

as

update 	
	[ERBRestaurant]
set 	
	[ServerIP] = @ServerIPAddress
	,[StaticIPAddress] = @StaticIP
	,[ServerPwd] = @ServerPass
where 	
	[RID] = @RestaurantID


update
	[Restaurant]
set
	[RestStateID] = @RestaurantStateID
	,[IsOptOutForFRNandBackSoon] = @IsOptOutForFRNandBackSoon
where
	[RID] = @RestaurantID


GO

grant execute on [Admin_Restaurant_UpdateServerInfo] to ExecuteOnlyRole

GO


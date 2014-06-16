
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTR_GetRestaurantWebSiteUrl]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTR_GetRestaurantWebSiteUrl]
go

/* This stored procedure is used to fetch website url for given rid */

create procedure [dbo].[OTR_GetRestaurantWebSiteUrl]
(
	@RID int
)
as
	SELECT 
            ExternalURL            
    FROM 
			RestaurantVW 
	WHERE 
			RID = @RID 

go
grant execute on [OTR_GetRestaurantWebSiteUrl] to ExecuteOnlyRole
go
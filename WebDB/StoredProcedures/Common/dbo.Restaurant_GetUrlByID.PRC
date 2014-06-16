if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_GetUrlByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_GetUrlByID]
GO



CREATE Procedure dbo.Restaurant_GetUrlByID
(
@RestaurantID int
,@retVal nvarchar(255) OUTPUT
)

AS
SET NOCOUNT ON
set transaction isolation level read uncommitted

select @retVal = ServerIP from ERBRestaurant where RID = @RestaurantID
GO

GRANT EXECUTE ON [Restaurant_GetUrlByID] TO ExecuteOnlyRole

GO

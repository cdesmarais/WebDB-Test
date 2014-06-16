if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_GetProductID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_GetProductID]
GO









CREATE PROCEDURE dbo.Restaurant_GetProductID
(
@RestaurantID int,
@RetVal int OUTPUT
)
AS
/*created 7-31-02 this sproc will get product id for given restaurant*/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

select @RetVal = ProductID from ERBRestaurant where RID = @RestaurantID
GO

GRANT EXECUTE ON [Restaurant_GetProductID] TO ExecuteOnlyRole

GO

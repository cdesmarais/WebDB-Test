if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTen_TopTenListRestaurantSuppression_Create]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TopTen_TopTenListRestaurantSuppression_Create]
GO


CREATE PROCEDURE [dbo].[TopTen_TopTenListRestaurantSuppression_Create]
(
    @TopTenListID int,    
    @RID int,  -- Restaurant ID
    @ModifiedBy nchar(255)  -- username of modifying user
)
As

Exec TopTen_TopTenListRestaurantSuppression_Create2 @TopTenListID, @RID, NULL, @ModifiedBy

GO

GRANT EXECUTE ON [dbo].[TopTen_TopTenListRestaurantSuppression_Create] TO ExecuteOnlyRole

GO


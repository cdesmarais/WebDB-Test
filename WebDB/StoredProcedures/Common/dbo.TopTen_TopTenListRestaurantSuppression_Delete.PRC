if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTen_TopTenListRestaurantSuppression_Delete]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TopTen_TopTenListRestaurantSuppression_Delete]
GO


CREATE PROCEDURE [dbo].[TopTen_TopTenListRestaurantSuppression_Delete]
(
    @TopTenListID int,    
    @RID int,  -- Restaurant ID  
    @ModifiedBy nchar(255)  -- username of modifying user
)
As

Exec TopTen_TopTenListRestaurantSuppression_Delete2 @TopTenListID, @RID, NULL, @ModifiedBy

GO



GRANT EXECUTE ON [dbo].[TopTen_TopTenListRestaurantSuppression_Delete] TO ExecuteOnlyRole

GO


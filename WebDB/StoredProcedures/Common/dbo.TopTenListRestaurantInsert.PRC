if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTenListRestaurantInsert]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TopTenListRestaurantInsert]
GO
/*	
	Procedure to insert a Top Ten list restaurant	
*/
CREATE PROCEDURE dbo.TopTenListRestaurantInsert

( @ListInstanceID		int
 ,@RID					int
 ,@Rank					int ) 

AS
SET NOCOUNT ON

------------------------------------------------------------------------------
-- Intersect the list instance with the restaurant
------------------------------------------------------------------------------
INSERT INTO [dbo].[TopTenListRestaurant]
           ([TopTenListInstanceID]
           ,[RID]
           ,[Rank])
     VALUES
           (@ListInstanceID
            ,@RID
            ,@Rank)
           
GO


GRANT EXECUTE ON [dbo].[TopTenListRestaurantInsert] TO ExecuteOnlyRole

GO


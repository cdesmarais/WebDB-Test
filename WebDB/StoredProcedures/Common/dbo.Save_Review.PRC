if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Save_Review]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Save_Review]
GO




CREATE Procedure dbo.Save_Review
(
 @RestaurantID int,
 @Meal_Type int,
 @Revisit bit,
 @Price int,
 @Prices int,
 @Food int,
 @Service int,
 @Atmosphere int,
 @WineList int,
 @Comments nvarchar(1000)
)
AS
SET NOCOUNT ON
Insert into Review (RID,MealTypeID,Revisit,MealPrice,MealPriceID,
 FoodRating,ServiceRating,AtmosphereRating,WineListRating,Comments,CustID)
VALUES
 (@RestaurantID,@Meal_Type,@Revisit ,@Price,@Prices,@Food,@Service,@Atmosphere,@WineList,@Comments,null)
GO

GRANT EXECUTE ON [Save_Review] TO ExecuteOnlyRole

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Review_Save]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Review_Save]
GO

CREATE Procedure dbo.Review_Save
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
 @Comments nvarchar(255),
 @CustomerID int
)
AS
SET NOCOUNT ON
DECLARE @TranName nvarchar(20),@CustID int
Select @TranName = 'MyTransaction'
SET TRAN ISOLATION LEVEL SERIALIZABLE
BEGIN TRANSACTION @TranName
Select @CustID = @CustomerID

if @CustomerID = 0 Select @CustID = Null

Insert into Review (RID,MealTypeID,Revisit,MealPrice,MealPriceID,
 FoodRating,ServiceRating,AtmosphereRating,WineListRating,Comments,CustID)
VALUES
 (@RestaurantID,@Meal_Type,@Revisit ,@Price,@Prices,@Food,@Service,@Atmosphere,@WineList,@Comments,@CustID)
if (@@ERROR <> 0) Goto general_error

COMMIT TRANSACTION @TranName
RETURN(0)

general_error:
ROLLBACK TRANSACTION @TranName
RAISERROR('47',17,1)
RETURN(1)

GO

GRANT EXECUTE ON [Review_Save] TO ExecuteOnlyRole

GO

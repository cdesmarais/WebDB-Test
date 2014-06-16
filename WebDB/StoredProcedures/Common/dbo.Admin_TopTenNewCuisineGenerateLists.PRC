if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_TopTenNewCuisineGenerateLists]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_TopTenNewCuisineGenerateLists]
GO



CREATE PROCEDURE [dbo].[Admin_TopTenNewCuisineGenerateLists] 
(
 @cuisineid	int
)
AS

DECLARE @cuisinename nvarchar(100)
DECLARE @TopTenListTypeID int
DECLARE @ListDisplayOrder int
DECLARE @MediaStoreFeedListID int
DECLARE @MetroAreaID int

--if this is a macro cuisine, add toptenlisttype and toptenlist records
IF @cuisineid IN (select distinct macro.FoodTypeID
		FROM                   RestaurantVW r
		INNER JOIN        FoodTypes micro
		ON                         r.RID = micro.RID
		INNER JOIN        FoodTypeSearchMap cm
		ON                         cm.FoodTypeID = micro.FoodTypeID
		INNER JOIN        FoodType macro
		ON                         macro.FoodTypeID   = cm.SearchFoodTypeID 
		and                        macro.LanguageID = r.LanguageID)
BEGIN

	--Check that this Cuisine does not have any lists generated yet, or a TopTenListType record
	--If it does, raise an error and exit
	if(SELECT COUNT(*) FROM TopTenList WHERE CuisineID = @cuisineid) > 0
	BEGIN
		RAISERROR('Lists already exist for this cuisine type',17,1)
		RETURN
	END
	
	if(SELECT COUNT(*) FROM TopTenListType WHERE CuisineID = @cuisineid) > 0
	BEGIN
		RAISERROR('ListType already exists for this cuisine',17,1)
		RETURN
	END
	
	
	BEGIN transaction

	--get cuisine name
	SELECT @cuisinename = FoodType From [dbo].[FoodType]
	WHERE FoodTypeID = @cuisineid

	SELECT @ListDisplayOrder = (MAX(DefaultDisplayOrder) + 1) FROM TopTenListType

	--insert the new cuisine row into TopTenListType
	INSERT into TopTenListType (ListName, ListDisplayOrderNationalOverride, TopTenListTypeClassID, CuisineID,DefaultDisplayOrder, MediaStore_FeedListID)
	VALUES (@cuisinename,0,2,@cuisineid,@ListDisplayOrder,20)

	SELECT @TopTenListTypeID = SCOPE_IDENTITY()

	SELECT @MediaStoreFeedListID = MediaStore_FeedListID FROM TopTenListType
	WHERE TopTenListTypeID = @TopTenListTypeID

	--Add rows to TopTenList table for every participating MetroArea 
	INSERT [dbo].[TopTenList] (
			 [TopTenListTypeID] 
			,[ListDisplayOrder] 
			,[MetroAreaID] 
			,[MediaStore_FeedListID]
			,[CuisineID]
		) 
	SELECT distinct @TopTenListTypeID, @ListDisplayOrder, mav.MetroAreaID,@MediaStoreFeedListID,@cuisineid
	FROM 	MetroAreaVW mav
	WHERE active = 1 OR metroareaname = 'Demoland'
	ORDER BY MetroAreaID

	IF @@ERROR != 0 
	BEGIN 
		ROLLBACK TRANSACTION 
		RAISERROR('general error',17,1)
		RETURN 
	END 
	ELSE 
		COMMIT TRANSACTION
	

END

GO

GRANT EXECUTE ON [Admin_TopTenNewCuisineGenerateLists] TO ExecuteOnlyRole

GO

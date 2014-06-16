if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_FoodType_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_FoodType_List]
GO


CREATE PROCEDURE dbo.Admin_FoodType_List
(
  @Food_Type_ID int = 0
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

if @Food_Type_ID = 0
  BEGIN
  
	--************************
	--** Retrieve the LanguageID based on the DB connection
	--** Error Out if no language Found
	--************************
	declare @LanguageID int
	exec @LanguageID = procGetDBUserLanguageID
  
    SELECT foodtypeID AS FoodTypeID,
		FoodType as Value 
	FROM FoodType 
	WHERE LanguageID = @LanguageID
	Order by FoodType
  
  END
if @Food_Type_ID <> 0
  BEGIN
    SELECT FoodType as Value FROM FoodType where foodtypeID = @Food_Type_ID
  END


GO

GRANT EXECUTE ON [Admin_FoodType_List] TO ExecuteOnlyRole

GO

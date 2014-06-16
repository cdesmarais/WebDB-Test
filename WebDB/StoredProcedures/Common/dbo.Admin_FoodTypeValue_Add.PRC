if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_FoodTypeValue_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_FoodTypeValue_Add]
GO

CREATE PROCEDURE dbo.Admin_FoodTypeValue_Add
 (
  @Food_Type_ID int,
  @Value nvarchar(255)
 )
As

SET NOCOUNT ON
--************************
--** Retrieve the LanguageID based on the DB connection
--** Error Out if no language Found
--************************
declare @LanguageID int
exec @LanguageID = procGetDBUserLanguageID

INSERT INTO FoodType
 (FoodTypeID,FoodType, LanguageID)
VALUES(@Food_Type_ID,@Value, @LanguageID)

GO

GRANT EXECUTE ON [Admin_FoodTypeValue_Add] TO ExecuteOnlyRole

GO

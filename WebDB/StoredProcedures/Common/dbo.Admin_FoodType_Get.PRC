if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_FoodType_Get]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_FoodType_Get]
GO




CREATE PROCEDURE dbo.Admin_FoodType_Get
 
  @FoodTypeID nvarchar(255)

As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--*****************************
--** Given a list of food type ids, return the set of FoodTypes
--** Used in Admin.dll to create a comma delimited list of foodtypes for a restaurant
--** Does not need a Language filter becuase the incoming IDs are already restricted by language
--*****************************
SELECT FoodType as Value 
FROM FoodType 
WHERE foodtypeID IN (select id from fIDStrToTab(@FoodTypeID, ','))


GO

GRANT EXECUTE ON [Admin_FoodType_Get] TO ExecuteOnlyRole

GO

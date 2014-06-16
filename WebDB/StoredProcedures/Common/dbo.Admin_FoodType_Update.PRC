if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_FoodType_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_FoodType_Update]
GO

CREATE PROCEDURE dbo.Admin_FoodType_Update
 (
  @Value nvarchar(255),
  @Food_Type_ID int
 )
As

SET NOCOUNT ON

--*****************************
--** Does not need a Language filter becuase the incoming IDs are already restricted by language
--*****************************
UPDATE FoodType
SET FoodType = @Value
WHERE foodtypeID =  @Food_Type_ID

GO

GRANT EXECUTE ON [Admin_FoodType_Update] TO ExecuteOnlyRole

GO

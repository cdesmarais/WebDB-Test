
/****** Object:  StoredProcedure [dbo].[Admin_GetRIDCount_ForSurvey]    Script Date: 03/26/2013 10:44:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Admin_GetRIDCount_ForSurvey]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Admin_GetRIDCount_ForSurvey]
GO

CREATE PROCEDURE [dbo].[Admin_GetRIDCount_ForSurvey]
@RID int

 AS
 
Set nocount on
Set transaction isolation level read uncommitted

select top 1 RestaurantSurveyID from RestaurantSurveyRestaurants where RID = @RID
GO


-- Set Permission 
GRANT EXECUTE ON [Admin_GetRIDCount_ForSurvey] TO ExecuteOnlyRole 
GO 


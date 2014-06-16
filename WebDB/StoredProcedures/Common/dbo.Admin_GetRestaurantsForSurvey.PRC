
/****** Object:  StoredProcedure [dbo].[Admin_GetRestaurantsForSurvey]    Script Date: 04/03/2013 13:41:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Admin_GetRestaurantsForSurvey]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Admin_GetRestaurantsForSurvey]
GO


CREATE PROCEDURE [dbo].[Admin_GetRestaurantsForSurvey]
(
	 @RestaurantSurveyID INT
)
 AS

Set transaction isolation level read uncommitted

select	RestaurantSurveyID, 
		RestaurantSurveyRestaurants.RID as RID, 
		r.RName as [Restaurant Name]

from	RestaurantSurveyRestaurants 
			inner join RestaurantVW  r
			on r.RID = RestaurantSurveyRestaurants.RID
where	RestaurantSurveyRestaurants.RestaurantSurveyID = @RestaurantSurveyID

GO

-- Set Permission 
GRANT EXECUTE ON [Admin_GetRestaurantsForSurvey] TO ExecuteOnlyRole 
GO 



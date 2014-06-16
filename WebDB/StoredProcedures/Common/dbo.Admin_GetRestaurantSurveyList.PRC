if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetRestaurantSurveyList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetRestaurantSurveyList]
GO

/****** Object:  StoredProcedure [dbo].[Admin_GetRestaurantSurveyList]    Script Date: 03/07/2013 08:19:29 ******/

CREATE PROCEDURE [dbo].[Admin_GetRestaurantSurveyList]

 AS
Set nocount on
Set transaction isolation level read uncommitted

Select rs.Name, rs.RestaurantSurveyID
from RestaurantSurveysVW rs

GO

GRANT EXECUTE ON [Admin_GetRestaurantSurveyList] TO ExecuteOnlyRole

GO



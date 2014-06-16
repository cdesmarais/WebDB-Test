if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetRestaurantSurveyTypes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetRestaurantSurveyTypes]
GO

/****** Object:  StoredProcedure [dbo].[Admin_GetRestaurantSurveyTypes]    Script Date: 03/07/2013 07:14:45 ******/


CREATE PROCEDURE [dbo].[Admin_GetRestaurantSurveyTypes]

AS

Set nocount on
Set transaction isolation level read uncommitted

select r.Name, 
	   r.RestaurantSurveyTypeID
	   
from RestaurantSurveyTypes r
GO

GRANT EXECUTE ON [Admin_GetRestaurantSurveyTypes] TO ExecuteOnlyRole

GO



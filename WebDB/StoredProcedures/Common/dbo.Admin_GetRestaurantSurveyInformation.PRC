if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetRestaurantSurveyInformation]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetRestaurantSurveyInformation]
GO
/****** Object:  StoredProcedure [dbo].[Admin_GetRestaurantSurveyInformation]    Script Date: 03/07/2013 08:14:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Admin_GetRestaurantSurveyInformation]

@SurveyID int

 AS
Set nocount on
Set transaction isolation level read uncommitted

Select RestaurantSurveyID, RestaurantSurveyTypeID, Name, Code, Active, Question, FeedbackYes, FeedbackInput, FeedbackNo
from RestaurantSurveysVW rs
where rs.RestaurantSurveyID = @SurveyID

GO

GRANT EXECUTE ON [Admin_GetRestaurantSurveyInformation] TO ExecuteOnlyRole

GO


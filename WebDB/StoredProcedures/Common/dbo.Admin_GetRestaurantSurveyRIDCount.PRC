
/****** Object:  StoredProcedure [dbo].[Admin_GetRestaurantSurveyRIDCount]    Script Date: 03/27/2013 10:21:53 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Admin_GetRestaurantSurveyRIDCount]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Admin_GetRestaurantSurveyRIDCount]
GO


CREATE PROCEDURE [dbo].[Admin_GetRestaurantSurveyRIDCount]

 AS
Set nocount on
Set transaction isolation level read uncommitted


select count(rs2.RID) as ActiveRIDs, rs1.Name, rs1.RestaurantSurveyID as SurveyID, rs1.UpdatedBy as UpdatedBy, convert(varchar(10) ,rs1.UpdatedDate, 101) as UpdatedDate 
 from dbo.RestaurantSurveys as rs1 left outer join dbo.RestaurantSurveyRestaurants as rs2 
on rs1.RestaurantSurveyID = rs2.RestaurantSurveyID
group by rs1.Name, rs1.RestaurantSurveyID, rs1.UpdatedDate, rs1.UpdatedBy

GO

-- Set Permission 
GRANT EXECUTE ON [Admin_GetRestaurantSurveyRIDCount] TO ExecuteOnlyRole 
GO 



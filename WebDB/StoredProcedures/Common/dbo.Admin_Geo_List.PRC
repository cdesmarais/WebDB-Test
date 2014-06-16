if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Geo_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Geo_List]
GO





CREATE PROCEDURE dbo.Admin_Geo_List
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Declare @Languages AS int
Select @Languages = count(DISTINCT LanguageID) from MetroAreaLocal

 SELECT		metroareaid as Metro_Area_ID,
			MetroAreaName as Name,
			Active,SearchLevel as Search_Level,
			Message,EmailContact as email_contact,
			metroareaid as GeoID,
			@Languages as Languages
  FROM		MetroAreaVW m
  ORDER BY	Name

GO

GRANT EXECUTE ON [Admin_Geo_List] TO ExecuteOnlyRole

GO

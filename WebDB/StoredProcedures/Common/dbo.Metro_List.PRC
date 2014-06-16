if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Metro_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Metro_List]
GO






CREATE Procedure dbo.Metro_List
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 SELECT		metroareaid as Metro_Area_ID
			,MetroAreaName as Name
			,Active
			,SearchLevel as Search_Level
			,Message
			,EmailContact as email_contact
			,metroareaid as GeoID
  FROM		MetroAreaVW
  ORDER BY	Name
GO

GRANT EXECUTE ON [Metro_List] TO ExecuteOnlyRole

GO

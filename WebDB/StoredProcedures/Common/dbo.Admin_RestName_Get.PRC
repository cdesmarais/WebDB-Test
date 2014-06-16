if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_RestName_Get]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_RestName_Get]
GO


CREATE PROCEDURE dbo.Admin_RestName_Get
 (
  @Neighborhood_ID int
 )
As
SET NOCOUNT ON

SELECT	RName as Name
FROM	RestaurantVW
WHERE	neighborhoodid = @Neighborhood_ID

GO

GRANT EXECUTE ON [Admin_RestName_Get] TO ExecuteOnlyRole

GO

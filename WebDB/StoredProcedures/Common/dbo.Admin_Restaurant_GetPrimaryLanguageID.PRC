if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_GetPrimaryLanguageID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_GetPrimaryLanguageID]
GO

CREATE PROCEDURE dbo.Admin_Restaurant_GetPrimaryLanguageID
(
@RestaurantID int
)
AS

SET nocount on 
SET TRANSACTION isolation  LEVEL  READ  uncommitted 

SELECT
	d.PrimaryLanguageID
FROM 
	restaurantVW r
INNER JOIN Neighborhood n
	ON r.NeighborhoodID = n.NeighborhoodID
INNER JOIN MetroArea m
	ON n.MetroAreaID = m.MetroAreaID
INNER JOIN Domain d
	ON m.SupportedDomainID = d.DomainID
WHERE r.rid = @RestaurantID


GO


GRANT EXECUTE ON [Admin_Restaurant_GetPrimaryLanguageID] TO ExecuteOnlyRole

GO


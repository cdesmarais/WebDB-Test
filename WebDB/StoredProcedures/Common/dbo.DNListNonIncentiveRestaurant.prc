if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNListNonIncentivesRestaurant]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNListNonIncentivesRestaurant]
GO

CREATE  PROCEDURE dbo.DNListNonIncentivesRestaurant

AS
SET NOCOUNT ON
set transaction isolation level read uncommitted


SELECT 
r.RID
,r.RName   
,r.RSName
,r.City
,r.State
,ma.MetroAreaName  
,ma.MetroAreaID 
FROM  RestaurantVW r 
INNER JOIN IncentiveRestaurantStatus i  
ON   i.RID = r.RID 
INNER JOIN RestaurantState rs  
ON   r.RestStateID = rs.RestStateID   
INNER JOIN Neighborhood n   
on r.NeighborhoodID = n.NeighborhoodID  
INNER JOIN MetroAreaLocal ma  
on n.MetroAreaID = ma.MetroAreaID  
and r.LanguageID = ma.LanguageID  
WHERE i.Active = 1							--- active incentive
AND i.IncStatusID = 2						--- Not a DIP Customer  
AND r.RestStateID IN (1, 5, 6, 7, 13, 16) 
ORDER BY  ma.MetroAreaName, r.RSName Asc, r.RName

GO

GRANT EXECUTE ON [DNListNonIncentivesRestaurant] TO ExecuteOnlyRole

GO


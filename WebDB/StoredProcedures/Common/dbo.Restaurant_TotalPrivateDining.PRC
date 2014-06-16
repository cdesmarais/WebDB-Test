if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_TotalPrivateDining]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_TotalPrivateDining]
GO

CREATE Procedure dbo.Restaurant_TotalPrivateDining
(
@MetroAreaID int 
)
As

SET NOCOUNT ON
set transaction isolation level read uncommitted


SELECT 		COUNT(*) as PDCount
FROM 		Restaurant r
INNER JOIN 	Neighborhood n
ON 		r.NeighborhoodID = n.NeighborhoodID
WHERE 		r.PublishPrivateDining =1
AND 		n.MetroAreaID = @MetroAreaID
GO

GRANT EXECUTE ON [Restaurant_TotalPrivateDining] TO ExecuteOnlyRole

GO

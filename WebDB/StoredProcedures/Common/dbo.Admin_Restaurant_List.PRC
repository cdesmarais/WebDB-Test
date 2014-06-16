if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_List]
GO

CREATE Procedure dbo.Admin_Restaurant_List
As

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

select		r.RID 'RestaurantID'  
			,r.RName   'RestaurantName'  
			,m.metroareaname 'MetroName' 	
			,m.metroareaID		 
 from		dbo.RestaurantVW r  
 inner join Neighborhood n    
 on			r.neighborhoodid = n.neighborhoodid    
 inner join MetroAreaVW m    
 on			n.metroareaid = m.metroareaid      
 order by	r.RName  

GO

GRANT EXECUTE ON [Admin_Restaurant_List] TO ExecuteOnlyRole

GO

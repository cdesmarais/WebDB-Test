


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetRestaurantGroupIDFrmLookup]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetRestaurantGroupIDFrmLookup]
GO


create procedure [dbo].[GetRestaurantGroupIDFrmLookup]  
(    
	@LookUpID int     
)    
as    

    
-- This stored procedure is used to get LookUpId(GroupID) and GroupName


Select
	ValueID    

from    
	ValueLookupIDList
	
where 
	[LookUpID]= @LookUpID  


GO

GRANT EXECUTE ON [GetRestaurantGroupIDFrmLookup] TO ExecuteOnlyRole

GO





if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_GetCountryID_ByRestaurantID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_GetCountryID_ByRestaurantID]
GO

create procedure dbo.[Restaurant_GetCountryID_ByRestaurantID]
(
	@RestaurantID int
)
AS

-- This procedure is used to get CountryID from Restaurant table by given RestaurantID

select	
	Country
	
from	 
	Restaurant

where	 
	RID = @RestaurantID

GO

GRANT EXECUTE ON [Restaurant_GetCountryID_ByRestaurantID] TO ExecuteOnlyRole

GO





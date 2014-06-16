if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_GetIncentiveID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_GetIncentiveID]
GO




/*
	Returns the Incentive ID for the reservation
	Returns null if no Incentive ID applies
*/
CREATE Procedure dbo.Reservation_GetIncentiveID

	@RestaurantID		int
,	@ResDateTime		datetime
,	@ResPromoID			int
,	@IncentiveID		int output

as

--Check for Incented Time Promo
declare 	@diningIncentive 	bit
		,	@incentive			int

select @diningIncentive = coalesce(DiningIncentive,0) 
from Promos 
where PromoID = @ResPromoID
if @diningIncentive = 1
	exec procIncentiveLookup @RestaurantID, @ResDateTime, @incentiveID OUTPUT
else
	set @incentive = null

--Return
set @IncentiveID = @incentive

return
GO

GRANT EXECUTE ON [Reservation_GetIncentiveID] TO ExecuteOnlyRole

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNReservationGetIncentiveID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNReservationGetIncentiveID]
GO

--*******************************************
--** EV: 1/11/2007: this proc is obsolete
--*******************************************

/*
	Returns the Incentive ID for the reservation
	Returns null if no Incentive ID applies
*/
CREATE PROCEDURE dbo.DNReservationGetIncentiveID

	@RestaurantID		int
, 	@ResDateTime		datetime
, 	@ResPromoID			int
, 	@IncentiveID		int output

as

--Check for Incented Time Promo
declare 	@diningIncentive 	bit
		, 	@incentive			int

select @diningIncentive = coalesce(DiningIncentive,0) 
from Promos 
where PromoID = @ResPromoID

if @diningIncentive = 1
	exec procIncentiveLookup @RestaurantID, @ResDateTime, @incentive OUTPUT
else
	set @incentive = null

--Return
set @IncentiveID = @incentive

return
GO



GRANT EXECUTE ON [DNReservationGetIncentiveID] TO ExecuteOnlyRole

GO

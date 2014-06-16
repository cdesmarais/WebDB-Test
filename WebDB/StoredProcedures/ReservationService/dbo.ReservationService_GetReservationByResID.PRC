if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ReservationService_GetReservationByResID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ReservationService_GetReservationByResID]
GO

create procedure dbo.ReservationService_GetReservationByResID
(
	@ResID int
)
as
set nocount on
set transaction isolation level read uncommitted

select		top 1	
			ReservationID = res.ResID,
      		RestaurantID = res.RID, 
      		ConfirmationNumber = res.ConfNumber,
      		OfferConfirmationNumber = ro.OfferConfNumber,
			Points = res.ResPoints,
			ReservationDateTime = (res.ShiftDate + 2 + res.ResTime),
      		PartySize = res.PartySize

from		reservation res
left join	ReservationOffer ro
on			res.resid = ro.ResID

where		res.ResID = @ResID
and			res.ConfNumber is NOT NULL

go

grant execute on [ReservationService_GetReservationByResID] to ExecuteOnlyRole

GO
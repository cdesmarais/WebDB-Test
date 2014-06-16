if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNReservationGetConfirmationAndRestaurantID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNReservationGetConfirmationAndRestaurantID]
GO

CREATE PROCEDURE dbo.DNReservationGetConfirmationAndRestaurantID
(
	@nReservationID int
)
 AS

set transaction isolation level read uncommitted

select 
RID as RestaurantID
,ConfNumber as ConfirmationNumber 
from Reservation 
where ResID = @nReservationID

GO

GRANT EXECUTE ON [DNReservationGetConfirmationAndRestaurantID] TO ExecuteOnlyRole

GO

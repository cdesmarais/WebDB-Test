if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_GetRestNameByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_GetRestNameByID]
GO

CREATE PROCEDURE dbo.Reservation_GetRestNameByID
(@ReservationID int
)

AS
 
SET NOCOUNT ON
set transaction isolation level read uncommitted

select r.Rname as name 
from RestaurantVW r
inner join Reservation 
on Reservation.RID = r.RID
where Reservation.ResID = @ReservationID

GO

GRANT EXECUTE ON [Reservation_GetRestNameByID] TO ExecuteOnlyRole

GO

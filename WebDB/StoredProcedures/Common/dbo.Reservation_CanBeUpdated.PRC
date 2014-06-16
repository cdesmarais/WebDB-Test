if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_CanBeUpdated]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_CanBeUpdated]
GO

CREATE PROCEDURE dbo.Reservation_CanBeUpdated  

(@ReservationID int,
@retval int OUTPUT
)

As
SET NOCOUNT ON
set transaction isolation level read uncommitted

if (Select RStateID from Reservation where ResID = @ReservationID) <> 1
	
select @retval = 0 --can't update a non-pending reso
Return(0)
if (Select (ShiftDate + 2 + ResTime ) from Reservation where ResID = @ReservationID) < getDate()

select @retval = 2 --can't update a Reservation which has passed
Return(2)

select @retval = 1 --otherwise,o.k. to update this reso
Return(1)
GO

GRANT EXECUTE ON [Reservation_CanBeUpdated] TO ExecuteOnlyRole

GO

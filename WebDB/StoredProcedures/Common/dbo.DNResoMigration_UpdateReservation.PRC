if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNResoMigration_UpdateReservation]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNResoMigration_UpdateReservation]
GO

--
-- Update the WebDB reservation with data from reso migration:
-- new ConfNumber, and possibly a new RID.
-- Must update a record to succeed.
--

CREATE Procedure dbo.DNResoMigration_UpdateReservation
 (
  @ReservationID int,
  @RestaurantID int,
  @ConfirmationNumber int
 )
As
SET NOCOUNT ON
set transaction isolation level read uncommitted

UPDATE  Reservation
SET      RID = @RestaurantID
        ,ConfNumber = @ConfirmationNumber
WHERE  (ResID = @ReservationID)
AND     ShiftDate >= DATEADD(d,-30, GETDATE()) -- Take advantage of Partion Key
AND     RStateID = 1 -- pending

if (@@rowcount < 1)
begin
    -- if this happens, we will fail the Migration transaction (not the XML task)
    raiserror('No reservations were modified by the reso migration; ResID(%d), RID(%d), ConfNumber(%d)'
                , 16, 1, @ReservationID, @RestaurantID, @ConfirmationNumber)
end

GO

GRANT EXECUTE ON [DNResoMigration_UpdateReservation] TO ExecuteOnlyRole

GO

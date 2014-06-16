if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_Cancel]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_Cancel]
GO





CREATE Procedure dbo.Reservation_Cancel
 (
  @ReservationID int
 )
As
SET NOCOUNT ON
--Per the BizRule resos older than 30 are not allowed to be updated
--Also ShiftDate needs to be added to the where clause to improve performance of the Partitioned Reservation Table

UPDATE Reservation
SET RStateID= 3,
	CancelledDate= getdate()
WHERE (ResID = @ReservationID)
AND ShiftDate >= DATEADD(d,-30, GETDATE())
--Delete from PromoUse where ResID = @ResID

/*to help optimize search sprocs,we no longer keep cancelled resos in the TemplateReservation table ...*/
Delete from TemplateReservation where ResID = @ReservationID
GO

GRANT EXECUTE ON [Reservation_Cancel] TO ExecuteOnlyRole

GO

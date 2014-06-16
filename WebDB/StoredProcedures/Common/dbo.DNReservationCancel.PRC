if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNReservationCancel]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNReservationCancel]
GO





CREATE Procedure dbo.DNReservationCancel
 (
  @ReservationID int,
  @WebCancel bit
 )
As
SET NOCOUNT ON

--Per the BizRule resos older than 30 are not allowed to be updated
--Also ShiftDate needs to be added to the where clause to improve performance of the Partitioned Reservation Table
-- Update the reservation, set the status to either 3 for Web Cacnel or 8 for ERB Cancel

declare @RowsAffected int

UPDATE Reservation
SET RStateID= (case when @WebCancel = 1 then 3 else 8 end),
	CancelledDate= getdate()
WHERE (ResID = @ReservationID)
AND ShiftDate >= DATEADD(d,-30, GETDATE())
AND RStateID not in (3, 8) -- disallow cancelled-to-cancelled transitions

select @RowsAffected = @@rowcount

/*to help optimize search sprocs,we no longer keep cancelled resos in the TemplateReservation table ...*/
Delete from TemplateReservation where ResID = @ReservationID

-- Return the Rowcount as a scalar value	
select @RowsAffected as RowsAffected

GO

GRANT EXECUTE ON [DNReservationCancel] TO ExecuteOnlyRole

GO

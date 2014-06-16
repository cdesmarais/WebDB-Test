if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DN3ReservationErbUpdateStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DN3ReservationErbUpdateStatus]
GO

--*********************************************
--** OBSOLETE: EV: Obsolete proc after launch of BRUP
--*********************************************

CREATE PROCEDURE dbo.DN3ReservationErbUpdateStatus
(
  @ReservationID int,
 @ResStateID		int

)
as
SET NOCOUNT ON
set transaction isolation level read uncommitted

--Per the BizRule resos older than 30 are not allowed to be updated
--Also ShiftDate needs to be added to the where clause to improve performance of the Partitioned Reservation Table

update Reservation
set    RStateID = @ResStateID
where  ResID        = @ReservationID
and	   ShiftDate >= DATEADD(d,-30, GETDATE())	
and    RStateID <> 3
return

GO

GRANT EXECUTE ON [DN3ReservationErbUpdateStatus] TO ExecuteOnlyRole

GO

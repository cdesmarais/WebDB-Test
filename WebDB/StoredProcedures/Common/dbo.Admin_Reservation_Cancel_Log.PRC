

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Reservation_Cancel_Log]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Reservation_Cancel_Log]
GO

CREATE PROCEDURE dbo.Admin_Reservation_Cancel_Log(
	@CancellationRestLogID int,
	@ResIDList varchar(8000)
)

AS

	insert into CancelReservationLog
	(
		CancellationRestLogID
		,ReservationID
	)
	select
		@CancellationRestLogID
		,id
	from
		fIDStrToTab(@ResIDList, ',')

GO

GRANT EXECUTE ON [Admin_Reservation_Cancel_Log] TO ExecuteOnlyRole

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ReservationTrackResoAlerts]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ReservationTrackResoAlerts]
GO

CREATE PROCEDURE dbo.ReservationTrackResoAlerts
 (
  @RID int,
  @ConfNumber nvarchar(50),
  @ReservationDate datetime,
  @InSynch int
 )
As
SET NOCOUNT ON


Insert into reservationResoAlert 
(
	RID, 
	ConfNumber, 
	ResDateTime, 
	DateLogged,
	InSynch
)
VALUES
(
	@RID,
	@ConfNumber,
	@ReservationDate,
	getdate(),
	@InSynch
)

GO

GRANT EXECUTE ON [ReservationTrackResoAlerts] TO ExecuteOnlyRole

GO

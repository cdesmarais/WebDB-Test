if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ReservationTrackChange]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ReservationTrackChange]
GO


CREATE Procedure dbo.ReservationTrackChange
 (
  @ReservationID int,
  @NewDateTime Datetime,
  @NewParty int
 )
As
SET NOCOUNT ON

-- Do nothing.

GO

GRANT EXECUTE ON [ReservationTrackChange] TO ExecuteOnlyRole

GO

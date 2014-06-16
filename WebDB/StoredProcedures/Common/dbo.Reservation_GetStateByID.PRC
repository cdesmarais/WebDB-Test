if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_GetStateByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_GetStateByID]
GO



CREATE Procedure dbo.Reservation_GetStateByID

@ReservationID int

AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Select RStateID as Reservation_State_ID from Reservation where ResID = @ReservationID
GO

GRANT EXECUTE ON [Reservation_GetStateByID] TO ExecuteOnlyRole

GO

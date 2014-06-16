if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Reservation_GetStateByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Reservation_GetStateByID]
GO




CREATE PROCEDURE dbo.Concierge_Reservation_GetStateByID

@ReservationID int

 AS

Select RStateID as Reservation_State_ID from Reservation where ResID = @ReservationID
GO

GRANT EXECUTE ON [Concierge_Reservation_GetStateByID] TO ExecuteOnlyRole

GO

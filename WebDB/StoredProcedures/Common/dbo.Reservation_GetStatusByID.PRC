if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_GetStatusByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_GetStatusByID]
GO



CREATE Procedure dbo.Reservation_GetStatusByID
(@ReservationID int
,@retVal nvarchar(255) OUTPUT
)

AS
select @retVal = RStateName from ReservationState where RStateID =
(select RStateID from Reservation where ResID = @ReservationID)
GO

GRANT EXECUTE ON [Reservation_GetStatusByID] TO ExecuteOnlyRole

GO

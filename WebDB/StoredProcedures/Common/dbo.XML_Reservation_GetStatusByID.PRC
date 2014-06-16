if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XML_Reservation_GetStatusByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XML_Reservation_GetStatusByID]
GO

CREATE PROCEDURE dbo.XML_Reservation_GetStatusByID
(@ReservationID int
)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

select RStateName as name
,CustID as UserID 
from Reservation 
inner join ReservationState 
on Reservation.RStateID = ReservationState.RStateID
where ResID = @ReservationID

GO

GRANT EXECUTE ON [XML_Reservation_GetStatusByID] TO ExecuteOnlyRole

GO

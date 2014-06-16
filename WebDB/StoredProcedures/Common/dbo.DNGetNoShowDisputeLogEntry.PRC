if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetNoShowDisputeLogEntry]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetNoShowDisputeLogEntry]
GO

CREATE PROCEDURE dbo.DNGetNoShowDisputeLogEntry
(
	@nReservationID int
)
 AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT
	ns.ResID as ReservationID,	
	res.ShiftDate as ReservationDate,
	ns.DisputeDate,
	rest.RID as RestaurantID,
	rest.RName as RestaurantName,
	res.ResPoints as Points,
	ns.Reason as DisputeStatus,
	ns.Message,
	ns.UserID as CustomerID,
	ns.IsCaller,
	ns.Reason as DisputeReason,
	ns.Resolved

FROM		LogNoShowDisputes as ns
inner join	Reservation as res
on			res.ResID = ns.ResID
inner join	RestaurantAVW as rest
on			rest.RID = res.RID
and			rest.LanguageID = res.LanguageID	

WHERE 
	res.ResID = @nReservationID
GO


GRANT EXECUTE ON [DNGetNoShowDisputeLogEntry] TO ExecuteOnlyRole

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetNoShowDisputeLogByUser]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetNoShowDisputeLogByUser]
GO


CREATE PROCEDURE dbo.DNGetNoShowDisputeLogByUser
(
	@nUserID int,
	@nIsAdmin int
)
 AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

if @nIsAdmin = 0 -- Regular caller
	Begin
	
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
			(cust.FName + ' ' + cust.LName) as FullName

			
		FROM		LogNoShowDisputes as ns
		inner join	Reservation as res
		on			res.ResID = ns.ResID
		inner join	RestaurantAVW as rest
		on			rest.RID = res.RID
		and			rest.LanguageID = res.LanguageID
		inner join	Customer as cust
		on			Cust.CustID = @nUserID
		WHERE 
			ns.IsCaller = @nIsAdmin and
			ns.UserID = @nUserID and 			
			cust.CustID = @nUserID
	End
else
	Begin
-- Admin
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
			(diner.FName + ' ' + diner.LName) as FullName

		FROM		LogNoShowDisputes as ns
		inner join	Reservation as res
		on			res.ResID = ns.ResID
		inner join	RestaurantAVW as rest
		on			rest.RID = res.RID
		and			rest.LanguageID = res.LanguageID
		inner join	CallerCustomer as diner
		on			diner.CustID = res.CustID
			
		WHERE 
			ns.UserID = @nUserID and 
			ns.IsCaller = @nIsAdmin and
			diner.CallerID = @nUserID

	End
GO



GRANT EXECUTE ON [DNGetNoShowDisputeLogByUser] TO ExecuteOnlyRole

GO

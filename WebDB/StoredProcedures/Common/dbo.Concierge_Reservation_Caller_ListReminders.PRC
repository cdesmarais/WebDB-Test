if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Reservation_Caller_ListReminders]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Reservation_Caller_ListReminders]
GO

CREATE Procedure dbo.Concierge_Reservation_Caller_ListReminders
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @Confirmation int
exec DNGetMessageTypeID 'Confirmation',@Confirmation output

SELECT 
			res.ResID AS ReservationID
			,cc.FName AS FirstName
			,cc.LName AS LastName
			,r.RName AS RestaurantName
			,r.Address1 AS RestaurantAddress
			,r.Phone AS RestaurantPhone
			,res.PartySize AS PartySize
			,res.ResTime AS ReservationTime
			,res.ConfNumber AS ConfirmationNumber
			,(case when sent.ResID is not null then convert(bit, 1) else res.ReminderSent end) AS ReminderSent
			,coalesce(rcm.Message,dbo.fGetRestaurantMessage(r.RID, @Confirmation)) AS RestaurantMessage
FROM		 Reservation res
left join	ReminderSentLog sent
on			res.ResID = sent.ResID
INNER JOIN	 CallerCustomer cc
ON			 res.CustID = cc.CustID 
INNER JOIN	 RestaurantVW r
ON			 res.RID = r.RID
left join	 RestaurantCustomMessage rcm
on           r.RID = rcm.RID
and          rcm.MessageTypeID = @Confirmation
and			 rcm.LanguageID = r.LanguageID
WHERE (DATEDIFF(DAY,res.DateMade,GETDATE()) > 0) 
AND (DATEDIFF(DAY,GETDATE(),res.ShiftDate) = 1) 
AND ((res.ReminderSent = 0) and (sent.ResID is null))
AND (res.RStateID = 1)
ORDER BY res.DateMade DESC

GO

GRANT EXECUTE ON [Concierge_Reservation_Caller_ListReminders] TO ExecuteOnlyRole

GO

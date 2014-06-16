if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Periodic_Reservation_ListReminders]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Periodic_Reservation_ListReminders]
GO

CREATE Procedure dbo.Periodic_Reservation_ListReminders
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT res.ResID AS ReservationID,
    Customer.FName AS FirstName,
    Customer.LName AS LastName,
    Customer.Email,r.RName AS RestaurantName,
    Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End AS PartySize,
    res.ResTime AS ReservationTime,
    res.ShiftDate as ShiftDate,
    res.ConfNumber AS ConfirmationNumber,
    (case when sent.ResID is not null then convert(bit, 1) else res.ReminderSent end) AS ReminderSent    
FROM Reservation res
left join	ReminderSentLog sent
on			res.ResID = sent.ResID
INNER JOIN  Customer 
ON res.CustID = Customer.CustID 
INNER JOIN RestaurantVW r 
ON   res.RID = r.RID
WHERE (DATEDIFF(DAY,res.DateMade,GETDATE()) > 0) 
AND (DATEDIFF(DAY,GETDATE(),res.ShiftDate) = 1) 
AND ((res.ReminderSent = 0) and (sent.ResID is null))
AND (res.RStateID = 1)
ORDER BY res.DateMade DESC

GO

GRANT EXECUTE ON [Periodic_Reservation_ListReminders] TO ExecuteOnlyRole

GO

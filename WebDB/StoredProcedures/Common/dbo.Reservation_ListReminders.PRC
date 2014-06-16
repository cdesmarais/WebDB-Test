if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_ListReminders]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_ListReminders]
GO


CREATE Procedure dbo.Reservation_ListReminders

As

SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @Confirmation int
exec DNGetMessageTypeID 'Confirmation',@Confirmation output

(SELECT 
		res.ResID AS ReservationID
		,res.RID as RestaurantID
		,c.FName AS FirstName
		,c.LName AS LastName
		,c.Email as Email
		,'' as CallerFirstName
		,''  as CallerEmail
		,0 as isAAUserReso
		,coalesce(res.incentiveid,0) as isIncentedDine
		,r.RName AS RestaurantName
		,r.Address1 AS RestaurantAddress
		, dbo.fFormatPhone(r.Phone, cn.countryCode) AS RestaurantPhone
		,res.PartySize AS PartySize
		,Right(Cast(res.ResTime as char(17)),5) + ' ' +Right(Cast(res.ResTime as char(19)),2) AS ReservationTime
		,(Cast(res.ShiftDate as char(11)))  AS ShiftDate
		,res.ConfNumber AS ConfirmationNumber
		,(case when sent.ResID is not null then convert(bit, 1) else res.ReminderSent end) AS ReminderSent    
		,coalesce(rcm.Message,dbo.fGetRestaurantMessage(r.RID, @Confirmation)) AS RestaurantMessage
        ,r.City AS City
        ,r.State AS State
        ,r.Zip  AS Postal_Code
        ,res.ResPoints as Points
        ,coalesce(r.CrossStreet,'') as CrossStreet
        ,ConsumerType as Consumer_Type
        ,res.CustID as CustomerID
        ,'' as Password
	,res.ShiftDate + 2 + res.ResTime as ResoDate    
FROM		Reservation res
left join	ReminderSentLog sent
on			res.ResID = sent.ResID
INNER JOIN	Customer c
ON			res.CustID = c.CustID
INNER JOIN	RestaurantVW r
ON			res.RID = r.RID
INNER JOIN CountryAVW cn
ON			cn.countryID = r.country
and			cn.LanguageID = r.LanguageID
left join   RestaurantCustomMessage rcm
on          r.RID = rcm.RID
and			r.LanguageID = rcm.LanguageID
and         rcm.MessageTypeID = @Confirmation
WHERE		res.CallerID is null 
AND			(DATEDIFF(DAY,res.DateMade,GETDATE()) > 0) 
AND			(DATEDIFF(DAY,GETDATE(),res.ShiftDate) = 1) 
AND			((res.ReminderSent = 0) and (sent.ResID is null))
AND			(res.RStateID = 1)

 )
UNION
(SELECT 
			res.ResID AS ReservationID
			,res.RID as RestaurantID
			,cc.FName AS FirstName
			,cc.LName AS LastName
			,cc.Email as Email
			,c.FName  as CallerFirstName
			,c.Email as CallerEmail
			,1 as isAAUserReso
			,coalesce(res.incentiveid,0) as isIncentedDine
			,r.RName AS RestaurantName
			,r.Address1 AS RestaurantAddress
			, dbo.fFormatPhone(r.Phone, cn.countryCode) AS RestaurantPhone
			,res.PartySize AS PartySize
			,Right(Cast(res.ResTime as char(17)),5) + ' ' + Right(Cast(res.ResTime as char(19)),2) AS ReservationTime
			,(Cast(res.ShiftDate as char(11)))  AS ShiftDate
			,res.ConfNumber AS ConfirmationNumber
			,(case when sent.ResID is not null then convert(bit, 1) else res.ReminderSent end) AS ReminderSent 
			,coalesce(rcm.Message,dbo.fGetRestaurantMessage(r.RID, @Confirmation)) AS RestaurantMessage
			,r.City AS City
			,r.State AS State
			,r.Zip  AS Postal_Code
			,res.ResPoints as Points
			,coalesce(r.CrossStreet,'') as CrossStreet
			,ConsumerType as Consumer_Type
			,res.CustID as CustomerID
			,'' as Password
			,res.ShiftDate + 2 + res.ResTime as ResoDate    

FROM       Reservation res
left join	ReminderSentLog sent
on			res.ResID = sent.ResID
INNER JOIN CallerCustomer cc
ON         res.CustID = cc.CustID 
INNER JOIN Caller c
on         res.CallerID = c.CallerID
inner join RestaurantVW r
ON         res.RID = r.RID 
INNER JOIN CountryAVW cn
ON			cn.countryID = r.country
and			cn.LanguageID = r.LanguageID
left join RestaurantCustomMessage rcm
on         r.RID = rcm.RID
and			r.LanguageID = rcm.LanguageID
and        rcm.MessageTypeID = @Confirmation
WHERE      res.CallerID is not null
AND        c.PositionID = 3
AND       (DATEDIFF(DAY,res.DateMade,GETDATE()) > 0) 
AND       (DATEDIFF(DAY,GETDATE(),res.ShiftDate) = 1) 
and		(ReminderSent	= 0 and sent.ResID is null) -- sent.ResID is not null when reminders sent using new method
AND       (res.RStateID = 1)
)

GO

GRANT EXECUTE ON [Reservation_ListReminders] TO ExecuteOnlyRole

GO

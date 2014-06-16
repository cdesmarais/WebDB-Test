if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_GetParams]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_GetParams]
GO

CREATE Procedure dbo.Reservation_GetParams
(
@UserID int,
@RestaurantID int,
@ResDateTime datetime,
@CallerID int = 0
)
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

if (@CallerID = 0) --GET Customer DATA
BEGIN
IF (SELECT COUNT(*) FROM Reservation
WHERE (CustID = @UserID)
AND (RID = @RestaurantID)
AND (RStateID = 1)
AND ABS(DATEDIFF(minute,(ShiftDate + 2 +ResTime),(@ResDateTime)))  <= 240
) > 0
RAISERROR('73',16,1) --'You already have a Reservation at this Restaurant near this time.'
-- Does this Customer already have more than one pending reservations during the requested shift?
IF (SELECT COUNT(*) FROM Reservation
WHERE (CustID = @UserID)
AND (RStateID = 1)
AND ABS(DATEDIFF(minute,(ShiftDate + 2 + ResTime) ,(@ResDateTime)))  <= 240
) > 0
RAISERROR('74',16,2) --'You already have a Reservation near this time'

SELECT 
Customer.FName AS FirstName
,Customer.LName AS LastName
,Customer.EMail
,ConsumerType as Consumer_Type
,'' as Password
FROM Customer
WHERE Customer.CustID = @UserID
END

if (@CallerID > 0) --GET Caller Customer DATA
BEGIN
-- Does this Customer already have any pending reservations at this restaurant
-- during the requested shift?
IF (SELECT COUNT(*) FROM Reservation
WHERE (CustID = @UserID)
AND (RID = @RestaurantID)
AND (RStateID = 1)
AND ABS(DATEDIFF(minute,(ShiftDate + 2 + ResTime) ,(@ResDateTime)))  <= 240
) > 0
RAISERROR('75',16,1) --'Your Customer already has a Reservation at this Restaurant near this time.'

-- Does this Customer already have more than one pending reservations during the requested shift?
IF (SELECT COUNT(*) FROM Reservation
WHERE (CustID = @UserID)
AND (RStateID = 1)
AND ABS(DATEDIFF(minute,(ShiftDate + 2 + ResTime) ,(@ResDateTime)))  <= 240
) > 0
RAISERROR('76',16,2) --'Your Customer already has a Reservation near this time.'



SELECT 
CallerCustomer.FName AS FirstName
,CallerCustomer.LName AS LastName
,Caller.FName As Admin_First
,Caller.LName As Admin_Last
,Caller.Email As AdminEmail
,CallerCustomer.EMail
,ConsumerType as Consumer_Type
,'' as Password
FROM CallerCustomer 
INNER JOIN Caller 
ON CallerCustomer.CallerID=Caller.CallerID
WHERE CallerCustomer.CustID = @UserID
END

declare @Confirmation int
exec DNGetMessageTypeID 'Confirmation',@Confirmation output

-- GET ERB DATA
SELECT er.ServerIP AS NetAddress
,er.serverPwd AS Password
,2 AS Version,
r.Allotment As Allotment,
(Case when er.FixedTimeOffset = 1 then -8
else tz._offsetHR END) AS TimeZoneOffset,
r.RName AS RestaurantName,r.Address1,
r.Address2,r.City,r.State,
r.Zip AS ZipCode,
r.Phone,
rm.RMDesc as Description
,IsNull(r.CrossStreet,'') As CrossStreet
,coalesce(rcm.Message,dbo.fGetRestaurantMessage(r.RID, @Confirmation))As Confirmation_Message
,(Case when er.ProductID >= 6 then 1 else 0 end) as SendWebCustID 

FROM ERBRestaurant er
INNER JOIN RestaurantVW r 
ON er.RID = r.RID 
INNER JOIN TimeZone tz 
ON r.TZID = tz.TZID 
INNER JOIN	RestaurantMessageAVW rm
ON			er.RID = rm.RID
and			r.LanguageId = rm.LanguageID
left join	 RestaurantCustomMessage rcm
on           r.RID = rcm.RID
and			 r.LanguageID = rcm.LanguageID
and          rcm.MessageTypeID = @Confirmation
WHERE (er.RID = @RestaurantID)
GO

GRANT EXECUTE ON [Reservation_GetParams] TO ExecuteOnlyRole

GO

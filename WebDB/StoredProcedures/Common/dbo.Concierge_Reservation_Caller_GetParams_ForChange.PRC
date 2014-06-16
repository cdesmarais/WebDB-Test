if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Reservation_Caller_GetParams_ForChange]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Reservation_Caller_GetParams_ForChange]
GO

CREATE Procedure dbo.Concierge_Reservation_Caller_GetParams_ForChange
 (
  @UserID int,
  @RestaurantID int,
  @ResDateTime datetime,
  @CallerID int,
  @OriginalReservationID int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

if (
		SELECT	COUNT(*) 
		FROM	Reservation
		WHERE	(CustID = @UserID)
		AND		ResID <> @OriginalReservationID
		AND		(RID = @RestaurantID)
		AND		(RStateID = 1)
		AND		(CallerID = @CallerID)
		AND		(CONVERT(nvarchar,ShiftDate,102) = CONVERT(nvarchar,@ResDateTime,102))
		AND		(datepart(hour,ResTime) - 4.0) / 24 / 12 = (datepart(hour,@ResDateTime) - 4.0) / 24 / 12
	) > 0
    RAISERROR('73',16,1)

if (
	  SELECT	COUNT(*) 
	  FROM		Reservation
	  WHERE		(CustID = @UserID)
	  AND		ResID <> @OriginalReservationID
	  AND		(CallerID = @CallerID)
	  AND		(RStateID = 1)
	  AND		(CONVERT(nvarchar,ShiftDate,102) = CONVERT(nvarchar,@ResDateTime,102))
	  AND	(datepart(hour,ResTime) - 4.0) / 24 / 12 = (datepart(hour,@ResDateTime) - 4.0) / 24 / 12
  ) > 1
    RAISERROR('74',16,2)
    
SELECT		CallerCustomer.FName AS FirstName,
			CallerCustomer.LName AS LastName,
			Caller.LName AS CallerLast,
			Caller.FName AS CallerFirst,
			CallerPhone.Phone AS CallerPhone,
			Company.CompanyName AS CallerCompany,
			Company.Phone AS CompanyPhone,
			CallerPhone.PhoneTypeID AS CallerIdentifier,
			Company.CompanyID AS CallerCompanyID

FROM		CallerCustomer
INNER JOIN	Caller ON CallerCustomer.CallerID = Caller.CallerID
INNER JOIN	CallerPhone ON CallerPhone.CallerID = Caller.CallerID AND CallerPhone.IsPrimary = 1
INNER JOIN	Company ON Caller.CompanyID = Company.CompanyID
WHERE		(CallerCustomer.CustID = @UserID)


declare @Confirmation int
exec DNGetMessageTypeID 'Confirmation',@Confirmation output

SELECT er.ServerIP AS NetAddress,
		er.serverPwd AS Password,
		ISNULL(ERBBuild,'') AS ERBVersion,
		CASE coalesce(er.Version,'')
  WHEN '1.0' THEN 1
  WHEN 'D1.00' THEN 2
  ELSE 0 END AS Version,
		r.Allotment As Allotment,
		(Case when er.FixedTimeOffset = 1 then -8
		else tz._offsetHR END) AS TimeZoneOffset,
		r.RName AS RestaurantName,r.Address1,
		r.Address2,r.City,r.State,
		r.Zip AS ZipCode,r.Phone,
		rm.RMDesc as Description
		,coalesce(rcm.Message,dbo.fGetRestaurantMessage(r.RID, @Confirmation)) As Confirmation_Message,
		(Case when er.ProductID >= 6 then 1
		else 0 end) as SendWebCustID 
FROM			ERBRestaurant er
INNER JOIN      RestaurantVW r
ON				er.RID = r.RID 
INNER JOIN		TimeZone tz
ON				r.TZID = tz.TZID 
INNER JOIN		RestaurantMessageVW rm 
ON				r.RID = rm.RID
AND				r.LanguageID = rm.LanguageID
left join		RestaurantCustomMessage rcm
on				r.RID = rcm.RID
and				r.LanguageID = rcm.LanguageID
and				 rcm.MessageTypeID = @Confirmation
WHERE			(er.RID = @RestaurantID)

select ConfNumber as ConfirmationNumber 
from Reservation 
where ResID = @OriginalReservationID
and RID = @RestaurantID

GO

GRANT EXECUTE ON [Concierge_Reservation_Caller_GetParams_ForChange] TO ExecuteOnlyRole

GO

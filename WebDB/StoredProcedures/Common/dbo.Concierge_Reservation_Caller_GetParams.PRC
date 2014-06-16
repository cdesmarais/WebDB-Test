if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Reservation_Caller_GetParams]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Reservation_Caller_GetParams]
GO

CREATE Procedure dbo.Concierge_Reservation_Caller_GetParams
 (
  @UserID int,
  @RestaurantID int,
  @ResDateTime datetime,
  @CallerID int
 )
As
--***************************************
--** Legacy APIs called by go.concierge uses opentable.dll
--***************************************

SET NOCOUNT ON
set transaction isolation level read uncommitted

if (SELECT COUNT(*) FROM Reservation
  WHERE (CustID = @UserID)
  AND (RID = @RestaurantID)
  AND (RStateID = 1)
  AND (CallerID = @CallerID)
  AND (CONVERT(nvarchar,ShiftDate,102) = CONVERT(nvarchar,@ResDateTime,102))
  AND (datepart(hour,ResTime) - 4.0) / 24 / 12 = (datepart(hour,@ResDateTime) - 4.0) / 24 / 12) > 0
    RAISERROR('73',16,1)
-- Does this user already have more than one pending reservations during the
-- requested shift?


if (SELECT COUNT(*) FROM Reservation
  WHERE (CustID = @UserID)
  AND (CallerID = @CallerID)
  AND (RStateID = 1)
  AND (CONVERT(nvarchar,ShiftDate,102) = CONVERT(nvarchar,@ResDateTime,102))
  AND (datepart(hour,ResTime) - 4.0) / 24 / 12 = (datepart(hour,@ResDateTime) - 4.0) / 24 / 12) > 1
    RAISERROR('74',16,2)

-- Get user data from - the innerjoins might be off
SELECT CallerCustomer.FName AS FirstName,
    CallerCustomer.LName AS LastName,
    Caller.LName AS CallerLast,
    Caller.FName AS CallerFirst,
    CallerPhone.Phone AS CallerPhone,
    Company.CompanyName AS CallerCompany,
    Company.Phone AS CompanyPhone,
    CallerPhone.PhoneTypeID AS CallerIdentifier,
    Company.CompanyID AS CallerCompanyID

FROM CallerCustomer 
INNER JOIN Caller 
ON CallerCustomer.CallerID = Caller.CallerID
INNER JOIN CallerPhone 
ON CallerPhone.CallerID = Caller.CallerID and CallerPhone.IsPrimary = 1
INNER JOIN Company 
ON Caller.CompanyID = Company.CompanyID
WHERE (CallerCustomer.CustID = @UserID)

-- Get ERB data. /Hasn't changed

declare @Confirmation int
exec DNGetMessageTypeID 'Confirmation',@Confirmation output

SELECT 
			ERBRestaurant.ServerIP AS NetAddress
			,ERBRestaurant.serverPwd AS Password
			,coalesce(ERBBuild,'') AS ERBVersion
			,CASE ISNULL(ERBRestaurant.Version,'') WHEN '1.0' THEN 1
			 WHEN 'D1.00' THEN 2
			ELSE 0 END AS Version
			,r.Allotment As Allotment
			,(Case when ERBRestaurant.FixedTimeOffset = 1 then -8 else tz._offsetHR END) AS TimeZoneOffset
			,r.RName AS RestaurantName
			,r.Address1
			,r.Address2
			,r.City
			,r.State
			,r.Zip AS ZipCode
			,r.Phone
			,rm.RMDesc as Description
			,coalesce(rcm.Message,dbo.fGetRestaurantMessage(r.RID, @Confirmation))As Confirmation_Message
			,(Case when ERBRestaurant.ProductID >= 6 then 1 else 0 end) as SendWebCustID 
FROM		 ERBRestaurant 
INNER JOIN	 RestaurantVW r 
ON			 ERBRestaurant.RID = r.RID 
INNER JOIN	 TimeZone tz 
ON			 r.TZID = tz.TZID 
INNER JOIN	 RestaurantMessageVW rm 
ON			 r.RID = rm.RID
AND			 r.LanguageID = rm.LanguageID
left join	 RestaurantCustomMessage rcm
on           r.RID = rcm.RID
AND			 r.LanguageID = rcm.LanguageID
and          rcm.MessageTypeID = @Confirmation
WHERE (ERBRestaurant.RID = @RestaurantID)
GO

GRANT EXECUTE ON [Concierge_Reservation_Caller_GetParams] TO ExecuteOnlyRole

GO

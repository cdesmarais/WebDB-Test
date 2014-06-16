if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_GetByConfirmationID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_GetByConfirmationID]
GO

CREATE  Procedure dbo.Reservation_GetByConfirmationID
 (
  @RestaurantID int,
  @ConfirmationID	int
 )
As
set nocount on
set transaction isolation level read uncommitted

SELECT res.ConfNumber AS Confirmation,
    res.ShiftDate + 2 + res.ResTime AS ResDateTime,
    Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End AS PartySize,
    res.CustID AS UserID,
    coalesce(res.CallerID,0) As CallerID,
    coalesce(Customer.FName,Caller.FName,'') AS FirstName,
    coalesce(Customer.LName,Caller.LName,'') AS LastName,
    coalesce(Customer.EMail,Caller.EMail,'') as EMail,
    dbo.fFormatPhone(res.ContactPhone, cn.countryCode) AS ContactPhone,
    r.RName AS RestaurantName,
    r.RID AS RestaurantID,
    r.Phone AS RestaurantPhone,
    Caller.FName AS Admin_First,
    Caller.LName AS Admin_Last,
    Caller.EMail As AdminEmail,ResID as Reservation_ID,
    RStateID as Reservation_State_ID
FROM		Reservation res
left JOIN	Customer 
ON			res.CustID = Customer.CustID
left JOIN	Caller 
ON			res.CallerID = Caller.CallerID 
and			Caller.PartnerID not in (5,16)
INNER JOIN	RestaurantAVW r
ON			res.RID = r.RID 
and			res.LanguageId = r.LanguageID
INNER JOIN CountryAVW cn
ON			cn.countryID = r.country
and			cn.LanguageID = r.LanguageID
WHERE		res.RID = @RestaurantID
--	and CHARINDEX(',' + ConfNumber + ',',',' + @ConfirmationID + ',') > 0
and			ConfNumber = @ConfirmationID 
and			res.RStateID <> 3

GO

GRANT EXECUTE ON [Reservation_GetByConfirmationID] TO ExecuteOnlyRole

GO

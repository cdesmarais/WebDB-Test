if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_GetProfileByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_GetProfileByID]
GO

CREATE PROCEDURE dbo.Admin_Restaurant_GetProfileByID
 (
  @RestaurantID int
 )
As
SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @Confirmation int
exec DNGetMessageTypeID 'Confirmation',@Confirmation output


SELECT r.RID AS RestaurantID,--0
    r.RName AS RestaurantName,--1
    '1' AS RestaurantUID,--2
    r.RestaurantType AS RestaurantType,--3
    r.MinOnlineOptionID AS MinOnlineOptionID,--4
    r.ParkingID AS ParkingID,--5
    r.SmokingID AS SmokingID,--6
    DressCodeID AS DressCodeID,--7
    r.PriceQuartileID AS PriceQuartileID,--8
    r.CreditCardID AS CreditCardID,--9
    r.WOID AS WalkinOptionID,--10
    r.TZID AS TimeZoneID,--11
    r.neighborhoodid AS NeighborhoodID,--13
    r.MaxOnlineOptionID AS MaxOnlineOptionID,--14
    r.MinTipSizeOptionID AS MinTipSizeOptionID,--15
    r.MaxAdvanceOptionID AS MaxAdvanceOptionID,--16
    r.RestStateID AS RestaurantStateID,--17
    DiningStyleID AS DiningStyleID,--18
    r.createdate AS CreateDate,--19
    r.Address1 AS Address1,--20
    r.Address2 AS Address2,--21
    r.City AS City,--22
    r.State AS State,--23
    r.Zip AS PostalCode,--24
    r.Country AS Country,--25
    r.BanquetPhone as BanquetPhone,--26
    r.Phone AS BusinessPhone,--27
    r.PrivatePartyPhone as PrivatePartyPhone,--28
    r.ReservationPhone as ReservationPhone,--29
    r.FaxPhone as FaxPhone,--30
    r.UpdatePwd AS UpdatePwd,--31
    r.Chef AS Chef,--32
    r.Email AS Email,--33
    r.ExternalURL AS ExternalURL,--34
    r.ReserveCode AS ReserveCode,--35
    r.BanquetContact AS BanquetContact,--36
    r.CrossStreet AS CrossStreet,--37
    r.PrivatePartyContact AS PrivatePartyContact,--38
    r.HasBanquet AS HasBanquet,--39
    r.HasCatering AS HasCatering,--40
    r.HasPrivateParty AS HasPrivateParty,--41
    r.Longitude AS Longitude,--42
    r.LegacyID AS LegacyID,--43
    r.Latitude AS Latitude,--44
    rm.CaterDescription AS CaterDescription,--45
    rm.RMDesc AS RestaurantMessage,--46
    rm.Entertainment AS Entertainment,--47
    rm.ParkingDescription AS ParkingDescription,--48
    rm.PrivatePartyDescription as  PrivatePartyDescription
    ,coalesce(rcm.Message,dbo.fGetRestaurantMessage(r.RID, @Confirmation)) AS ConfirmationMessage,--50
    rm.PublicTransit AS PublicTransit,--51
    rm.Hours AS Hours,--52
     rm.BanquetDescription  AS BanquetDescription,--53
    r.GiftCertificateCode AS GiftCertificateCode,--54
    r.HasGiftCertificate AS HasGiftCertificate,--55
    er.ServerIP AS ERPServerIP,--56
    er.serverPwd AS ERPServerPwd,--57
    er.ServerKey AS ERPServerKey,--58
    ltc.LTC AS ERPLastTimeContacted,--59
    2 AS ERPVersion,--60
    r.Allotment AS Allotment,--61
    r.Ping AS IPPing,--62
    er.ProductID as Product_ID,--63
    coalesce(RestaurantNetvisit.NetvisitID,0) as NetvisitID, --64
    rm.SpecialEvents AS SpecialEvents,--65
    r.MaxLargePartyID AS MaxLargePartySize, -- 66 
    er.StaticIPAddress AS IsStaticIP, -- 67
    coalesce(Logo,'0') as RestaurantLogo, -- 68
    coalesce(ImageName,'0') as RestaurantImage, -- 69
    r.MenuURL, --70,
    r.MappingAddress,--71
	CONVERT(INT,r.MapAddrValid) AS MapAddrValid,--72
	c.MapLink --73

FROM		RestaurantVW r
INNER JOIN  RestaurantMessageVW rm
ON			r.RID = rm.RID 
and			r.LanguageID = rm.LanguageID
INNER JOIN  ERBRestaurant er
ON			r.RID = er.RID
Inner JOIN	LastTimeContacted ltc
on			r.RID = ltc.RID
Left Outer Join RestaurantNetvisit 
on			r.RID = RestaurantNetvisit.RID
Left Outer Join RestaurantImage 
on			r.RID = RestaurantImage.RID
left join   RestaurantCustomMessage rcm
on          r.RID = rcm.RID
and			r.LanguageID = rcm.LanguageID
and         rcm.MessageTypeID = @Confirmation
LEFT JOIN	CountryAVW c
ON			c.CountryID = r.Country
and			c.LanguageID = r.LanguageID
WHERE      (r.RID = @RestaurantID)

GO


GRANT EXECUTE ON [Admin_Restaurant_GetProfileByID] TO ExecuteOnlyRole

GO

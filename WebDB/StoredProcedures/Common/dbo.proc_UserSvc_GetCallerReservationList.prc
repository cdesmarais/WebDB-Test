if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[proc_UserSvc_GetCallerReservationList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[proc_UserSvc_GetCallerReservationList]
GO

CREATE Procedure dbo.proc_UserSvc_GetCallerReservationList
 (
  @UserID int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT res.ResID AS ReservationID,
    res.ShiftDate + 2 + res.ResTime AS ReservationDateTime,
    r.RID AS RestaurantID,
	r.RName as RestaurantName,
    res.RStateID AS ReservationState,
    ResPoints as Points,
    PartySize as PartySize,
    res.CustID AS DinerID,
    Dateadd(mi, -tz._offsetMI, (res.ShiftDate + 2 + res.ResTime)) AdjResoToUtcTime,
	l.LanguageCode as Language, -- Can be removed after Web_13_20
	l.LanguageCode as LanguageCode,
	l.LanguageID as LanguageID,
	d.DomainID as DomainID,
	d.Domain as DomainName,
	d.PublicSite as DomainURL,
	pl.LanguageID as DomainPrimaryLanguageID,
	pl.LanguageCode as DomainPrimaryLanguageCode,
	res.ConfNumber,
	res.Notes,
	res.CCEnabled,
	ISNULL(offer.OfferID, 0) as OfferID,
	ISNULL(offer.VersionID, 0) as VersionID,
	ISNULL(offer.OfferConfNumber, 0) as OfferConfNumber,
	ISNULL(roffer.OfferClassID, 0) as OfferClassID

FROM (
	select  res.ResID,
			res.rid,
			res.confnumber,
			res.languageid,
			res.ShiftDate,
			res.ResTime,
			res.RStateID,
			ResPoints,
			PartySize,
			custid,
			callerid,
			res.Notes,
			(case when LEN(ISNULL(res.CreditCardLastFour, '')) > 0 then 1 else 0 end)  as CCEnabled,
			res.PartnerId,
			res.ContactPhone
	from	Reservation res 
	where	callerid = @UserID
	--** Only consider Pending Resos (use a 8 day look back to be safe as assumed seated job looks at resos 7 days back)
	and		shiftdate > getdate() - 8
	and		res.RStateID = 1
) res	
INNER JOIN	RestaurantAVW r
ON			r.RID = res.RID
AND			r.LanguageID = res.LanguageID
inner join 	Language l
on			res.LanguageID = l.LanguageID
inner join 	Domain d
on			r.DomainID = d.DomainID
inner join 	Language pl
on			d.PrimaryLanguageID= pl.LanguageID
INNER JOIN	TimeZoneVW tz
ON			r.TZID = tz.TZID
LEFT JOIN	ReferrerRestaurantReservationVW rr
on			res.ResID = rr.resid 
and			res.RID = rr.RID
left join	ReservationOffer offer
on			res.ResID = offer.ResID
left join	ReservationOfferVW roffer
on			offer.OfferID = roffer.OfferID 
left join 	PartnerWhiteLabel pwl
on   		res.PartnerID = pwl.PartnerID
WHERE		pwl.PartnerID is null -- we want to EXCLUDE any reservations made by white label 
order by ReservationDateTime desc

GO


GRANT EXECUTE ON [proc_UserSvc_GetCallerReservationList] TO ExecuteOnlyRole
GO
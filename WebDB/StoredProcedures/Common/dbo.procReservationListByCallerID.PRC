if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procReservationListByCallerID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procReservationListByCallerID]
GO

CREATE Procedure dbo.procReservationListByCallerID
(
	@UserID int
)
--Removing the WIT Recompile option as per the DBA meeting as it causes high CPU usage and it was determined that it is not needed any more
--WITH RECOMPILE  -- Caller operations tend to get bad query plans; recompiling will help

As

--**************************************************
--** This proc is called by: DNReservationListByUserID
--** this proc must return the same result set as it's parent: DNReservationListByUserID
--** This proc exists as a standalone so that it can be recompiled
--** proc was split to improve performance for callers
--**************************************************

SET NOCOUNT ON
set transaction isolation level read uncommitted


SELECT res.ResID AS ReservationID,
    res.ShiftDate + 2 + res.ResTime AS ReservationDateTime,
     r.RID AS RestaurantID,
    r.RName AS RestaurantName,r.City,
    r.State,
    res.RStateID AS ReservationState,
    ResPoints as Points,
    PartySize as PartySize,
    tz._OffsetHR Offset,
    res.CustID AS DinerID,
    Dateadd(mi, LocalToServerOffsetMi, (res.ShiftDate + 2 + res.ResTime)) AdjResoToServerTime,
    (case when rr.RID is not null then 1 else 0 end) as IsRestReferred
	,l.LanguageCode as Language
	,pl.LanguageCode AS PrimaryLanguage
	,d.PublicSite as Domain
	,res.ConfNumber
	,res.Notes
	,res.CCEnabled
	,offer.OfferID
	,offer.VersionID
	,offer.OfferConfNumber
	,roffer.OfferClassID
	,res.ContactPhone
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
			res.ContactPhone
	from	Reservation res 
	where	callerid = @UserID
	--** Only consider Future Pending Resos (use a 2 day look back to be safe)
	and		shiftdate > getdate() - 2
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
WHERE		res.CallerID=@UserID
and			(res.RStateID = 1)
   -- Timzezone relative comparison; Erb Reso converted to Server Local
AND			Dateadd(mi, LocalToServerOffsetMi, (res.ShiftDate + 2 + res.ResTime)) > getdate()
order by ReservationDateTime


GO

GRANT EXECUTE ON [procReservationListByCallerID] TO ExecuteOnlyRole

GO

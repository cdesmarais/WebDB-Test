if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNReservationListByUserID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNReservationListByUserID]
GO

CREATE Procedure dbo.DNReservationListByUserID
 (
  @UserID int,
  @IsCaller int=0
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted


if @IsCaller=0 
BEGIN
	SELECT res.ResID AS ReservationID,
	    res.ShiftDate + 2 + res.ResTime AS ReservationDateTime,
	     r.RID AS RestaurantID,
	    r.RName AS RestaurantName,
		r.Address1, 
		r.Address2,
		r.City,
	    r.State,
		r.Zip,
	    res.RStateID AS ReservationState,
	    ResPoints as Points,
	    PartySize as PartySize,
	    tz._OffsetHR Offset,
	    @UserID AS DinerID,
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
				res.notes,
				(case when LEN(ISNULL(res.CreditCardLastFour, '')) > 0 then 1 else 0 end)  as CCEnabled,
				res.PartnerId,
				res.ContactPhone
		from	Reservation res 
		where	custid = @UserID
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
	left join 	PartnerWhiteLabel pwl
	on   		res.PartnerID = pwl.PartnerID
	-- Timzezone relative comparison; Erb Reso converted to Server Local
	WHERE		Dateadd(mi, LocalToServerOffsetMi, (res.ShiftDate + 2 + res.ResTime)) > getdate()
	and   		pwl.PartnerID is null -- we want to EXCLUDE any reservations made by white label 
	order by ReservationDateTime
	
	----
	-- For User Suggestions create a secondary return set for customer only
	-- since caller is not part of the user suggestion module.  This is to account
	-- for the gap between the daily job that compiles the diner's list of recent and
	-- disliked restaurants and any current activity.
	----
	SELECT res.ResID AS ReservationID,
    res.ShiftDate + 2 + res.ResTime AS ReservationDateTime,
    res.RID AS RestaurantID,    
    res.RStateID AS ReservationState    
	from Reservation res
	where	custid = @UserID
	and		shiftdate > getdate() - 3
		
END
if @IsCaller=1
BEGIN

	--** Call a proc this will force
	exec procReservationListByCallerID @UserID
	
END

GO

GRANT EXECUTE ON [DNReservationListByUserID] TO ExecuteOnlyRole

GO

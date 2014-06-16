if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procDNUserAcctAll__Caller_whenZero]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procDNUserAcctAll__Caller_whenZero]
GO

CREATE PROCEDURE dbo.procDNUserAcctAll__Caller_whenZero
(
    @UserID int,
    @TodayDate datetime,
	@AdminCustID int, --custid of the admin / null for regular customers
	@OriginalCustID int --original custid of the admin account if it was converted from a regular account; NULL for regular customers

)
AS
--*************************************************************
--** IMPORTANT: Please review any changes to this proc against:
--**	procDNUserAcctAll__Caller_whenZero
--**	procDNUserAcctAll__Cust_whenZero
--**
--** These procs are part of a pair. 
--** They are split to make it easier to diff (for logical symmetry)
--** and for performance reasons
--*************************************************************


SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED



--****************************
--** Retrieve future pending resos (callers)
--****************************
	select	ShiftDate + 2 + ResTime as ActivityDate,
			'Dine' as ActivityType,
			r.RName as ActivityDesc,
			ResPoints as ActivityValue,
			@AdminCustID as AdminCustID, --custid of the admin / null for regular customers
			@OriginalCustID as OriginalCustID, --original custid of the admin account if it was converted from a regular account; NULL for regular customers
			res.CustID as ResoCustID, --CustID on the reservation
			r.RID as EventID,
			res.ResID as ID,
			(case when rr.RID is not null then 1 else 0 end) as IsRestReferred,
			l.LanguageCode as Language,
			pl.LanguageCode AS PrimaryLanguage,
			d.PublicSite as Domain,
			res.RStateID as ReservationState,
			offer.OfferID,
			offer.VersionID,
			offer.OfferConfNumber,
			roffer.OfferClassID			
	from		Reservation res
	inner join	RestaurantAVW r
	on			r.RID = res.RID
	and			r.LanguageID = res.LanguageID
	inner join 	Language l
	on			res.LanguageID = l.LanguageID
	inner join 	Domain d
	on			r.DomainID = d.DomainID
	inner join 	Language pl
	on			d.PrimaryLanguageID= pl.LanguageID
	inner join 	timezoneVW tz 
	on			tz.tzid	= r.tzid
	LEFT OUTER JOIN ReferrerRestaurantReservationVW rr
	on			res.ResID = rr.resid
	and			res.RID = rr.RID
	left join	ReservationOffer offer
	on			res.ResID = offer.ResID
	left join	ReservationOfferVW roffer
	on			offer.OfferID = roffer.OfferID	
	left join 	PartnerWhiteLabel pwl
	on   		res.PartnerID = pwl.PartnerID 
	where		res.CallerID = @UserID
	and			RStateID in (1)
	-- Partion optimization to only look at data in the partitions that are gauranteed to contain future data
	-- the clause which follows is even more restrictive
	and			shiftdate > (@TodayDate - 5) 
	and			Dateadd(mi, LocalToServerOffsetMi, (res.ShiftDate + 2 + res.ResTime)) > @TodayDate -- Only show Reso in the future; based on converted time		
	and   		pwl.PartnerID is null -- we want to EXCLUDE any reservations made by white label partners	
	order by ActivityDate desc 


GO


GRANT EXECUTE ON [procDNUserAcctAll__Caller_whenZero] TO ExecuteOnlyRole

go

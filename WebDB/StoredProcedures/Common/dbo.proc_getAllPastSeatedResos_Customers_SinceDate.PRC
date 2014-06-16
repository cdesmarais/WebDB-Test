IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[proc_getAllPastSeatedResos_Customers_SinceDate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[proc_getAllPastSeatedResos_Customers_SinceDate]
GO

--gets reservations from a specified date (@SinceDate) and partner id
--from the PartnerAppToCustomer table.  Note that this is likely NOT the partner that's actually
--attributed to the reservation so there's no constraint on Reservation.PartnerId
CREATE PROCEDURE [dbo].[proc_getAllPastSeatedResos_Customers_SinceDate]
(
	@SinceDate	datetime,
	@PartnerID	int
)
AS

--*************************************************************
--** IMPORTANT: Please review any changes to this proc against:
--**	User_getAllPastReservations_Callers
--**
--** These procs are part of a pair. 
--** They are split to make it easier to diff (for logical symmetry)
--** and for performance reasons
--*************************************************************

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	create table #Reservations
	(
		ResID	int,
		ResDateTime	datetime,
		shiftdate	datetime,
		ConfNumber	int,
		PartySize	int,
		CustID	int,
		CallerID	int,
		RID	int,
		RStateID	int,
		ResPoints	int,
		PartnerID	int,
		LanguageID	int
	)
	
	insert into #Reservations
	select 
		ResID,
		ShiftDate + 2 + ResTime as ResDateTime,
		shiftdate,
		ConfNumber,
		PartySize,
		r.CustID,
		CallerID,
		RID,
		RStateID,
		ResPoints,
		r.PartnerID,
		LanguageID
	from Reservation r
	inner join PartnerAppToCustomer p on p.PartnerID = @PartnerID
	and p.CustID = r.CustID
	where shiftdate >= @SinceDate
	
	--****************************
	--** Retrieve Reso Activity
	--** a) Past Pending Resos
	--** b) Positive Final State Resos and all concierge resose regardless of points
	--**
	--****************************
	select res.ResID as ID,
		res.ResDateTime,
		res.PartySize,
		res.ConfNumber,
		r.RID as RestaurantID,
		r.RName as RestaurantName,
		r.Address1 as Address1,
		r.Address2 as Address2,
		r.City as City,
		r.State as State,
		r.ZIP as ZIP,
		r.Country,
		tz.GMTTZOffsetmin as UtcOffsetMinutes,
		(case when RStateID in (1,2,5,6,7) then ResPoints else 0 end) as ResPoints,
		null as AdminCustID, --custid of the admin / null for regular customers
		null as OriginalCustID, --original custid of the admin account if it was converted from a regular account; NULL for regular customers
		coalesce(res.CallerID, res.CustID) as ResoCustID, --CustID on the reservation
		cc.FName as DinerFirstName,
		cc.LName as DinerLastName,
		cc.SFname as DinerSortableFirstName,
		cc.SLname as DinerSortableLastName,
		l.LanguageCode as Language,
		pl.LanguageCode AS PrimaryLanguage,
		d.PublicSite as Domain,
		res.RStateID as ReservationState,
		cc.Email as Email,
		sc.SiteUserID as SocialId
	from #Reservations res
	inner join	RestaurantAVW r
			on	r.RID = res.RID
			and	r.LanguageID = res.LanguageID
	inner join 	Language l
	on			res.LanguageID = l.LanguageID
	inner join 	Domain d
	on			r.DomainID = d.DomainID
	inner join 	Language pl
	on			d.PrimaryLanguageID= pl.LanguageID
	inner join 	timezoneVW tz 
			on	tz.tzid	= r.tzid
	inner join	Customer cc
			on	cc.CustID = res.CustID
	left join 	PartnerWhiteLabel pwl
	       on	res.PartnerID = pwl.PartnerID
	left join	SocialCustomer sc
			on	res.CustID = sc.CustID
			and sc.SocialTypeID = 1 -- only want FB users for now
	where 
		-- Partion optimization to only look at data in the partitions that are gauranteed to contain future data
		-- the clause which follows is even more restrictive
			shiftdate >= @SinceDate
		and ResDateTime >= @SinceDate
			and (RStateID in (2,4,5,6,7,10) 
				--Seated reso only show if positive points or made after they converted from anonymous
				and (Dateadd(mi, LocalToServerOffsetMi, ResDateTime) > @SinceDate)
			)
		and pwl.PartnerID is null -- we want to EXCLUDE any reservations made by white label partners
	order by ResDateTime desc 


GO

GRANT EXECUTE ON [dbo].[proc_getAllPastSeatedResos_Customers_SinceDate] TO ExecuteOnlyRole

GO




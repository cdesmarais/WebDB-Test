if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[proc_User_getAllPastSeatedReservations_Caller]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[proc_User_getAllPastSeatedReservations_Caller]
GO

CREATE PROCEDURE dbo.proc_User_getAllPastSeatedReservations_Caller
(
    @UserID int,
	@CreateDate as  datetime,
	@PartnerID int
)
AS

--*************************************************************
--** IMPORTANT: Please review any changes to this proc against:
--**	User_getAllPastReservations_Customer
--**	User_getAllPastReservations_Caller
--**
--** These procs are part of a pair. 
--** They are split to make it easier to diff (for logical symmetry)
--** and for performance reasons
--*************************************************************

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	Declare @AdminCustID int
	Declare @OriginalCustID int
	
	-- Set the AdminCustId and Original CustID
	-- For Customers these values are always null; 
	-- for Callers this represents the CallerCustID (AdminCustID) 
	--     and the original customer id (id before user converted to a caller)
	Select 			@AdminCustID = cc.CustID,
					@OriginalCustID = c.CustID
	From			CallerCustomer cc
	Left Join		Customer c 
	On 				cc.CallerID = c.CallerID
	Where			cc.CallerID = @UserID
	And				cc.IsAdmin = 1

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
		CustID,
		CallerID,
		RID,
		RStateID,
		ResPoints,
		PartnerID,
		LanguageID
	from Reservation
	where shiftdate > (@CreateDate - 5)
		-- Complete set of resos we care about: seated
		and RStateID in (2,5,6,7)
		and	CallerID = @UserID

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
		@AdminCustID as AdminCustID, --custid of the admin / null for regular customers
		@OriginalCustID as OriginalCustID, --original custid of the admin account if it was converted from a regular account; NULL for regular customers
		res.CustID as ResoCustID, --CustID on the reservation
		cc.FName as DinerFirstName,
		cc.LName as DinerLastName,
		cc.SFname as DinerSortableFirstName,
		cc.SLname as DinerSortableLastName,
		l.LanguageCode as Language,
		pl.LanguageCode AS PrimaryLanguage,
		d.PublicSite as Domain,
		res.RStateID as ReservationState,
		cal.EMail as Email,
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
	inner join	CallerCustomer cc
		on		cc.CallerID = res.CallerID
		and		cc.CustID = res.CustID
	inner join Caller cal
		on		cal.CallerID = res.CallerID
	left join 	PartnerWhiteLabel pwl
	       on	res.PartnerID = pwl.PartnerID
	left join	SocialCaller sc
			on	res.CallerID = sc.CallerID
			and sc.SocialTypeID = 1 -- only want FB users for now
	where res.CallerID = @UserID
		-- Partion optimization to only look at data in the partitions that are gauranteed to contain future data
		-- the clause which follows is even more restrictive
		and	shiftdate > (@CreateDate - 5) 		
		and ResDateTime >= @CreateDate
			and (RStateID in (2,4,5,6,7,10) 
				--Seated reso only show if positive points or made after they converted from anonymous
				and (Dateadd(mi, LocalToServerOffsetMi, ResDateTime) > @CreateDate)
			)
		and pwl.PartnerID is null -- we want to EXCLUDE any reservations made by white label partners
	order by ResDateTime desc 

GO


GRANT EXECUTE ON [proc_User_getAllPastSeatedReservations_Caller] TO ExecuteOnlyRole

go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[procEmailGet24HourReminder]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[procEmailGet24HourReminder]
GO


CREATE PROCEDURE [dbo].[procEmailGet24HourReminder]
	@dtNow datetime
as
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--	declare @dtNow datetime
--	set @dtNow = getdate()

	---------------------------------------------------------------------
	-- Large queries against the Reservation table take a long time due
	-- partly to the fact that the row set it not limited until after
	-- the joins to the other tables.  This temp table is used to limit
	-- the row set as early as possible to increase performance.
	--
	-- Note: In this case a table variable was found to be slower than
	-- a temp table - even though the stored procedure is recompiled
	-- every time it runs.
	--
	-- Modified to pass @dtNow as a parameter to the stored procedure
	-- so the QO will know the value of the parameter and will
	-- eliminate unnecessary partitions.
	--
	---------------------------------------------------------------------
	set ROWCOUNT 50000		-- Limit the record returned by select to 50k use this syntax instead of top, because this is easier to transformed into a paramter
	create table #Reservation
	( 
		 ResID			int
		,LanguageID		int
		,CustID			int
		,CallerID		int
		,RID			int
		,IncentiveID	int
		,PartySize		int
		,ResTime		datetime
		,ShiftDate		datetime
		,DateMade		datetime
		,ConfNumber		int
		,ReminderSent	bit
		,ResPoints		int
		,PartnerID		int
		PRIMARY KEY (ResID)
	)
	insert into #Reservation
	select
		res.ResID
			,LanguageID
			,CustID
			,CallerID
			,RID
			,IncentiveID
			,PartySize
			,ResTime
			,ShiftDate
			,DateMade
			,ConfNumber
			,(case when sent.ResID is not null then convert(bit, 1) else res.ReminderSent end) AS ReminderSent    
			,ResPoints
			,res.PartnerID  
	from 	Reservation res
	left join	ReminderSentLog sent
	on			res.ResID = sent.ResID
	inner join	Partner p
	on			res.PartnerID = p.PartnerID
	where	RStateID		= 1
	-- ShiftDate range is wide enough to cover 'tomorrow' in all time zones
	and		ShiftDate		between (@dtNow-1) and (@dtNow+2)
	and		(ReminderSent	= 0 and sent.ResID is null) -- sent.ResID is not null when reminders sent using new method
	-- Only return rows where the partner wants emails sent
	and		p.EmailOn		= 1
	order by shiftdate, restime -- Since record set is limited via ROWCOUNT this prevents starvation ensures FIFO
	---------------------------------------------------------------------
	-- Get the result set using the temp table instead of the full
	-- Reservation table
	---------------------------------------------------------------------
	declare	 @Confirmation	int
	exec DNGetMessageTypeID 'Confirmation',@Confirmation output

	(
		select		 res.ResID			'ReservationID'
					,res.RID			'RestaurantID'
					,res.LanguageID
					,r.DomainID
					,c.FName			'FirstName'
					,c.LName			'LastName'
					,c.Email			'Email'
					,''					'CallerFirstName'
					,''					'CallerLastName'
					,''					'CallerEmail'
					,0					'isAAUserReso'
					,coalesce(res.IncentiveID, 0)					'isIncentedDine'
					,r.RName										'RestaurantName'
					,r.Address1										'RestaurantAddress'
					,dbo.fFormatPhone(r.Phone, cn.CountryCode)		'RestaurantPhone'
					,res.PartySize									'PartySize'
					,res.ShiftDate + 2 + res.ResTime				'ResDateTime'
					,res.ConfNumber									'ConfirmationNumber'
					,res.ReminderSent								'ReminderSent'
					,coalesce(rcm.Message,dbo.fGetRestaurantMessage(r.RID, @Confirmation))	'RestaurantMessage'
					,r.City											'City'
					,r.State										'State'
					,r.Zip											'Postal_Code'
					,res.ResPoints									'Points'
					,coalesce(r.CrossStreet,'')						'CrossStreet'
					,ConsumerType									'Consumer_Type'
					,res.CustID										'CustomerID'
					,''												'Password'
					,MacroID										'MacroID'
					,coalesce(rrr.rid, 0)							'RestRef'
					,coalesce(c.SFName,'')							'SortableFirstName'
					,coalesce(c.SLName,'')							'SortableLastName'
					,d.Domain
					,c.Points										'PointsBalance'
					,ro.OfferConfNumber								'ConfirmationOfferNumber'
					,res.PartnerID
					,(case when coalesce(m.ShortDisplayName,'') != '' then ShortDisplayName else MetroAreaName end) AS MetroShortName    
					,m.MetroAreaName								'MetroName'
		from		#Reservation res
		inner join	Customer c
		on			c.CustID				= res.CustID
		inner join	RestaurantAVW r
		on			r.RID					= res.RID
		and			r.LanguageID			= res.LanguageID
		inner join	TimeZoneVW tz
		on			tz.TZID					= r.TZID
		inner join	Domain d
		on			d.DomainID				= r.DomainID
		inner join	Country cn
		on			cn.countryID			= r.country
		inner join	Neighborhood n
		on			n.NeighborhoodID		= r.NeighborhoodID
		inner join	MetroAreaAVW m
		on			m.metroareaID		= n.metroareaID
		and			m.LanguageID			= res.LanguageID
		left join	ReferrerRestaurantReservationVW rrr
		on			rrr.RID					= r.RID
		and			rrr.ResID				= res.ResID
		left join	RestaurantCustomMessage rcm
		on			rcm.RID					= r.RID
		and			rcm.LanguageID			= r.LanguageID
		and			rcm.MessageTypeID		= @Confirmation
		left join 	ReservationOffer	ro
		on 			res.ResID				= ro.ResID		
		where		res.CallerID										is null
		-- Reso must be for tomorrow
		and			DATEDIFF(DAY, tz.CurrentLocalTime, res.ShiftDate)	= 1
		-- Reso must be made yesterday or earlier
		and			DATEDIFF(DAY, DateMade, tz.CurrentLocalTime)		> 0
	)
	UNION ALL
	(
		select		 res.ResID		'ReservationID'
					,res.RID		'RestaurantID'
					,res.LanguageID
					,r.DomainID
					,cc.FName		'FirstName'
					,cc.LName		'LastName'
					,c.Email		'Email'
					,c.FName		'CallerFirstName'
					,c.LName		'CallerLastName'
					,c.Email		'CallerEmail'
					,1				'isAAUserReso'
					,coalesce(res.incentiveid,0)					'isIncentedDine'
					,r.RName										'RestaurantName'
					,r.Address1										'RestaurantAddress'
					,dbo.fFormatPhone(r.Phone, cn.countryCode)		'RestaurantPhone'
					,res.PartySize									'PartySize'
					,res.ShiftDate + 2 + res.ResTime				'ResDateTime'
					,res.ConfNumber									'ConfirmationNumber'
					,res.ReminderSent								'ReminderSent'
					,coalesce(rcm.Message,dbo.fGetRestaurantMessage(r.RID, @Confirmation))	'RestaurantMessage'
					,r.City											'City'
					,r.State										'State'
					,r.Zip											'Postal_Code'
					,res.ResPoints									'Points'
					,coalesce(r.CrossStreet,'')						'CrossStreet'
					,ConsumerType									'Consumer_Type'
					,res.CustID										'CustomerID'
					,''												'Password'
					,MacroID										'MacroID'
					,coalesce(rrr.rid, 0)							'RestRef'
					,coalesce(cc.SFName,'')							'SortableFirstName'
					,coalesce(cc.SLName,'')							'SortableLastName'
					,d.Domain
					,c.Points										'PointsBalance'
					,ro.OfferConfNumber								'ConfirmationOfferNumber'
					,res.PartnerID
					,(case when coalesce(m.ShortDisplayName,'') != '' then ShortDisplayName else MetroAreaName end) AS MetroShortName    
					,m.MetroAreaName								'MetroName'
		from		#Reservation res
		inner join	CallerCustomer cc
		on			cc.CustID				= res.CustID 
		inner join	Caller c
		on			c.CallerID				= res.CallerID
		inner join	RestaurantAVW r
		on			r.RID					= res.RID
		and			r.LanguageID			= res.LanguageID
		inner join	TimeZoneVW tz
		on			tz.TZID					= r.TZID
		inner join	Domain d
		on			d.DomainID				= r.DomainID
		inner join	Country cn
		on			cn.countryID			= r.country
		inner join	Neighborhood n
		on			n.NeighborhoodID		= r.NeighborhoodID
		inner join	MetroAreaAVW m
		on			m.metroareaID		= n.metroareaID
		and			m.LanguageID			= res.LanguageID
		left join	ReferrerRestaurantReservationVW rrr
		on			rrr.RID					= r.RID
		and			rrr.ResID				= res.ResID
		left join	RestaurantCustomMessage rcm
		on			rcm.RID					= r.RID
		and			rcm.LanguageID			= r.LanguageID
		and			rcm.MessageTypeID		= @Confirmation
		left join 	ReservationOffer ro
		on 			res.ResID				= ro.ResID		
		where		res.CallerID										is not null
		-- Admin Assistants only; Never concierges		
		and			c.PositionID										= 3
		-- Reso must be for tomorrow
		and			DATEDIFF(DAY, tz.CurrentLocalTime, res.ShiftDate)	= 1
		-- Reso must be made yesterday or earlier
		and			DATEDIFF(DAY, DateMade, tz.CurrentLocalTime)		> 0
	)
GO


GRANT EXECUTE ON procEmailGet24HourReminder TO ExecuteOnlyRole
GO


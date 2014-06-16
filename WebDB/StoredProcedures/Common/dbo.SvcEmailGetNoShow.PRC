if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SvcEmailGetNoShow]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SvcEmailGetNoShow]
GO


CREATE PROCEDURE dbo.SvcEmailGetNoShow
AS
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	declare @dtNow datetime
	set @dtNow = getdate()

	---------------------------------------------------------------------
	-- Large queries against the Reservation table take a long time due
	-- partly to the fact that the row set it not limited until after
	-- the joins to the other tables.  This temp table is used to limit
	-- the row set as early as possible to increase performance.
	--
	-- Note: In this case a table variable was found to be faster than
	-- a temp table (contrary to the 24-hour reminder query).  Both were
	-- tested for performance and the table variable was about 2x faster.
	---------------------------------------------------------------------
	declare @Reservation table
	( 
		 ResID			int
		,LanguageID		int
		,CustID			int
		,CallerID		int
		,RID			int
		,ResDateTime	datetime
		,ShiftDate		datetime
		,ResTime		datetime
		PRIMARY KEY (ResID)
	)

	set ROWCOUNT 50000		-- Limit the record returned by select to 50k use this syntax instead of top, because this is easier to transformed into a paramter
	insert into @Reservation
	select 	 ResID
			,LanguageID
			,CustID
			,CallerID
			,RID
			,ShiftDate + 2 + ResTime 'ResDateTime'
			,ShiftDate
			,ResTime
	from 	Reservation res
	inner join		Partner p
	on		res.PartnerID = p.PartnerID 
	where	res.RStateID	= 4 
	and		res.ShiftDate	> (@dtNow-14) -- limit to past 14 days for index efficiency
	and		not exists (select nsl.ResID from NoShowEmailSentLog nsl where nsl.ResID = res.ResID) 
	-- Only return rows where the partner wants emails sent
	and		p.EmailOn = 1
	order by shiftdate, restime -- Since record set is limited via ROWCOUNT this prevents starvation ensures FIFO

	---------------------------------------------------------------------
	-- Get the result set using the temp table instead of the full
	-- Reservation table
	---------------------------------------------------------------------
	select		 res.RID				'RID'
				,res.ResID				'ResID'
				,res.LanguageID
				,r.DomainID				
				,r.RName				'RName'
				,res.ResDateTime		'ResDateTime'
				,case
				when (res.CustID is not null and res.CallerID is null) then
					c.FName + ' ' + c.LName + '<OT_BR>' + coalesce(c.Email,'webdev@opentable.com') 
					+ '<OT_BR>' + cast(c.ConsumerType as nvarchar(5)) + '<OT_BR>' + cast(c.Active as nvarchar(5)) 
				when res.CallerID is not null then
					ca.FName + ' ' + ca.LName + '<OT_BR>' + coalesce(ca.Email,'webdev@opentable.com') 
					+ '<OT_BR>' + cast(ca.ConsumerType as nvarchar(5)) + '<OT_BR>' + 
					(case when(ca.PositionID = 2) then '2' else cast(ca.CallerStatusID as nvarchar(5)) end) 
				end						'theCustomerFulName'
				, case
					when (res.CustID is not null and res.CallerID is null) then c.FName
					when res.CallerID is not null then ca.FName
				end 'CustomerFirstName'
				, case
					when (res.CustID is not null and res.CallerID is null) then c.LName
					when res.CallerID is not null then ca.LName
				end 'CustomerLastName'
				, case
					when (res.CustID is not null and res.CallerID is null) then coalesce(c.Email,'webdev@opentable.com') 
					when res.CallerID is not null then coalesce(ca.Email,'webdev@opentable.com')
				end 'CustomerEmail'
				, case
					when (res.CustID is not null and res.CallerID is null) then cast(c.ConsumerType as nvarchar(5)) 
					when res.CallerID is not null then cast(ca.ConsumerType as nvarchar(5))
				end 'CustomerType'
				, case
					when (res.CustID is not null and res.CallerID is null) then cast(c.Active as nvarchar(5)) 
					when res.CallerID is not null then (case when(ca.PositionID = 2) then '2' else cast(ca.CallerStatusID as nvarchar(5)) end)
				end 'CustomerIsActive'
				
	from		@Reservation res
	inner join	RestaurantAVW r
	on			r.rid			= res.rid
	and			r.LanguageID	= res.LanguageID
	inner join	TimeZoneVW tz
	on			tz.TZID			= r.TZID
	left join	Customer c
	on			c.CustID		= res.CustID
	and			res.CallerID	is null
	left join	Caller ca
	on			ca.CallerID		= res.CallerID
	-- Ensure that 24 hours have past from the local time @ restaurant and reso date
	where		ResDateTime		< tz.CurrentLocalTime - 1
	order by	ResID asc 
GO


GRANT EXECUTE ON [SvcEmailGetNoShow] TO ExecuteOnlyRole
GO

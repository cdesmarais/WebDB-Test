IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[procEmailGetCancelAllPendingForRestaurant]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[procEmailGetCancelAllPendingForRestaurant]
GO


CREATE PROCEDURE [dbo].[procEmailGetCancelAllPendingForRestaurant]
	@dtNow DATETIME
AS
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--	DECLARE @dtNow DATETIME
--	SET @dtNow = GETDATE()
BEGIN
	---------------------------------------------------------------------
	-- Large queries against the Reservation table take a long time due
	-- partly to the fact that the row set it not limited until after
	-- the joins to the other tables.  This temp table is used to limit
	-- the row set as early as possible to increase performance.
	--
	-- Modified to pass @dtNow as a parameter to the stored procedure
	-- so the QO will know the value of the parameter and will
	-- eliminate unnecessay partitions.
	---------------------------------------------------------------------
	SET ROWCOUNT 50000		-- Limit the record returned by select to 50k use this syntax instead of top, because this is easier to transformed into a paramter
	CREATE TABLE #Reservation
	( 
		 ResID			INT
		,LanguageID		INT
		,CustID			INT
		,CallerID		INT
		,RID			INT
		,ResTime		DATETIME
		,ShiftDate		DATETIME
		,NotesToDiner	NVARCHAR(999)
		PRIMARY KEY (ResID)
	)
	
BEGIN
	INSERT INTO #Reservation
	SELECT
		 res.ResID
		,res.LanguageID
		,res.CustID
		,res.CallerID
		,res.RID
		,res.ResTime
		,res.ShiftDate
		,restlog.NotesToDiner
	FROM 		Reservation AS res
	-- Restaurant must have entry in "CancelRestaurantLog"
	INNER JOIN	
	(	-- notes-to-diner per reservation
		Select  
			c_restLog.RID
			,c_restLog.NotesToDiner
			,c_resoLog.ReservationID
		from 
			CancelReservationLog c_resoLog
			inner join CancelRestaurantLog c_restLog
			on c_resoLog.CancellationRestLogID = c_restLog.CancellationRestLogID
	) AS restlog
	ON			res.RID = restlog.RID and res.ResID = restlog.ReservationID
	LEFT JOIN   CancellationSentLog AS sentlog
	ON			res.ResID = sentlog.ResID
	WHERE		
	-- Reservation state is "Cancelled Restaurant"
	res.RStateID			= 8
	-- ShiftDate is definitely not in the past for all time zones
	AND		res.ShiftDate		>= (@dtNow-1)
	-- Cancellation email notice has *not* been sent
	AND		sentlog.ResID IS NULL 
	ORDER BY res.ShiftDate, res.ResTime -- Since record set is limited via ROWCOUNT this prevents starvation ensures FIFO
END

	---------------------------------------------------------------------
	-- Get the result set using the temp table instead of the full
	-- Reservation table
	---------------------------------------------------------------------
	(
		SELECT		 res.ResID			'ReservationID'
					,res.RID			'RestaurantID'
					,res.LanguageID
					,r.DomainID
					,c.FName			'FirstName'
					,c.LName			'LastName'
					,c.Email			'Email'
					,r.RName										'RestaurantName'
					,dbo.fFormatPhone(r.Phone, cn.CountryCode)		'RestaurantPhone'
					,res.ShiftDate + 2 + res.ResTime				'ResDateTime'
					,res.CustID										'CustomerID'
					,res.NotesToDiner
					,coalesce(c.SFName,'')							'SortableFirstName'
					,coalesce(c.SLName,'')							'SortableLastName'
					,ro.OfferConfNumber								'OfferConfirmationNumber'
		FROM		#Reservation res
		INNER JOIN	Customer c
		ON			c.CustID				= res.CustID
		INNER JOIN	RestaurantAVW r
		ON			r.RID					= res.RID
		AND			r.LanguageID			= res.LanguageID
		INNER JOIN	TimeZoneVW tz
		ON			tz.TZID					= r.TZID
		INNER JOIN	Country cn
		ON			cn.countryID			= r.country
		LEFT JOIN   dbo.ReservationOffer ro
		ON			ro.ResID = res.ResID
		WHERE		res.CallerID			is null	
		-- Reso must be for tomorrow or later
		AND			DATEDIFF(DAY, tz.CurrentLocalTime, res.ShiftDate)	>= 1
	)
	UNION ALL
	(
		SELECT		 res.ResID		'ReservationID'
					,res.RID		'RestaurantID'
					,res.LanguageID
					,r.DomainID
					,cc.FName		'FirstName'
					,cc.LName		'LastName'
					,c.Email		'Email'
					,r.RName										'RestaurantName'
					,dbo.fFormatPhone(r.Phone, cn.countryCode)		'RestaurantPhone'
					,res.ShiftDate + 2 + res.ResTime				'ResDateTime'
					,res.CustID										'CustomerID'
					,res.NotesToDiner
					,coalesce(cc.SFName,'')							'SortableFirstName'
					,coalesce(cc.SLName,'')							'SortableLastName'
					,ro.OfferConfNumber								'OfferConfirmationNumber'
		FROM		#Reservation res
		INNER JOIN	CallerCustomer cc
		ON			cc.CustID				= res.CustID 
		INNER JOIN	[Caller] c
		ON			c.CallerID				= res.CallerID
		INNER JOIN	RestaurantAVW r
		ON			r.RID					= res.RID
		AND			r.LanguageID			= res.LanguageID
		INNER JOIN	TimeZoneVW tz
		ON			tz.TZID					= r.TZID
		INNER JOIN	Country cn
		ON			cn.countryID			= r.country
		LEFT JOIN   dbo.ReservationOffer ro
		ON			ro.ResID = res.ResID
		WHERE		res.CallerID			is not null
		-- Admin Assistants only; Never concierges		
		AND			c.PositionID			= 3
		-- Reso must be for tomorrow or later
		AND			DATEDIFF(DAY, tz.CurrentLocalTime, res.ShiftDate)	>= 1
	)
END

GO


GRANT EXECUTE ON procEmailGetCancelAllPendingForRestaurant TO ExecuteOnlyRole
GO

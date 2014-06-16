if exists (select * from dbo.sysobjects where ID = object_id(N'[dbo].[procEmailGetDiningFeedback2]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[procEmailGetDiningFeedback2]
GO

-- Get list of cusotmers that fit the dining feedback form Email
CREATE PROCEDURE [dbo].[procEmailGetDiningFeedback2]
(
	@StartDt		datetime
	,@EndDt			datetime
	,@EmailGapHours	int
	,@nStartHour	int
	,@nEndHour		int
)
AS

		set nocount on
		set transaction isolation level read uncommitted 

		DECLARE @error int
		
		---------------------------------------------------------------------
		
		CREATE TABLE #resoselect(ResID int NOT NULL,
								ShiftDate datetime NOT NULL,
								RStateID int NOT NULL,
								CallerID int NULL,
								CustID int NOT NULL,
								ResTime datetime NOT NULL,
								RID int NOT NULL,
								PartnerID int NULL,
								LanguageID int NULL) 

		INSERT INTO #resoselect (ResID, ShiftDate, RStateID, CallerID, CustID, ResTime, RID, PartnerID, LanguageID)
		SELECT				Res.ResID, 
							Res.ShiftDate, 
							Res.RStateID, 
							Res.CallerID, 
							Res.CustID, 
							Res.ResTime, 
							Res.RID, 
							Res.PartnerID, 
							Res.LanguageID
		FROM		Reservation Res
		-- Do not process reservations that have already been processed
				
		WHERE				Res.RStateID in (2,5,7)
		AND					Res.LanguageID in (1,2,3,70) -- Only allow resos from COM, JP, DE and COUK
		AND					Res.ShiftDate >= @StartDT 
		AND					Res.ShiftDate <= @EndDT 
		and					not exists ( select DFF.ResID from DFBEmailSentLog DFF where DFF.ResID = res.ResID )	
				
		IF EXISTS (SELECT * FROM #resoselect)
		BEGIN
				set ROWCOUNT 50000		-- Limit the record returned by select to 50k use this syntax instead of top, because this is easier to transformed into a paramter	
				select				 res.ResID
									,res.LanguageID
									,res.CustID
									,res.RID
									,res.PartnerID
									,res.ShiftDate + 2 + res.ResTime 'ResDateTime'
									,res.ShiftDate
									,res.ResTime
									,res.CallerID
				into				#ReservationDFF
				from 				#resoselect res
				inner join			PartnerPartnerParameter p
					on 					res.PartnerID = p.PartnerID
					and					p.PartnerParameterID = 14
				inner join 			RestaurantAVW r 	
					on					r.RID					= res.RID
					and					r.LanguageID			= res.LanguageID
				inner join 			TimeZoneVW tz 
					on					tz.TZID					= r.TZID
				inner join 			Neighborhood n 
					on					n.NeighborhoodID		= r.NeighborhoodID
				inner join			MetroArea m
					on					m.MetroAreaID			= n.MetroAreaID 
					and					m.DFFStartDT			is not null
				left join			Caller c
					on					c.CallerID				= res.CallerID
				left join			CallerCustomer cc
					on					cc.CallerID				= c.CallerID 
					and 				cc.IsAdmin = 1 -- join only to the Admin's record in CallerCustomer
				-- >>>>> INDEXED BY ShiftDate and RStateID NC4
				where 				( (c.PositionID = 3 and (c.CallerID = res.CallerID and cc.CustID = res.CustID)) OR (c.PositionID IS NULL) )
				--and					not exists ( select ResID from DFBEmailSentLog where ResID = res.ResID )	
				AND					res.ShiftDate + 2 + res.ResTime			< DATEADD(hour, -@EmailGapHours, tz.CurrentLocalTime)
				-- make sure we're in the send window, use local time
				and					DATEPART(hh, DATEADD(hour, -@EmailGapHours, tz.CurrentLocalTime)) >=			@nStartHour
				and					DATEPART(hh, DATEADD(hour, -@EmailGapHours, tz.CurrentLocalTime)) <=			@nEndHour
				-- Check that this partner wants DFF mails sent
				and					p.ParameterValue = '1'
				order by shiftdate -- Since record set is limited via TOP this prevents starvation ensures FIFO
		
				select @error = @@error
				if @error != 0 goto ErrBlock
		
				declare	 @DFBPartnerIDExclusionList	int
						,@DFBRefIDExclusionList		int
						,@DFBRestIDExclusionList	int
						,@DFBRestRefIDExclusionList	int
				
				select @DFBPartnerIDExclusionList	= LookupID from ValueLookupMaster where [Type] = N'WEBSERVER'	and	[Key] = N'DFBPartnerIDExclusionList'
				select @DFBRefIDExclusionList		= LookupID from ValueLookupMaster where [Type] = N'WEBSERVER'	and	[Key] = N'DFBRefIDExclusionList'
				select @DFBRestIDExclusionList		= LookupID from ValueLookupMaster where [Type] = N'WEBSERVER'	and	[Key] = N'DFBRestIDExclusionList'
				select @DFBRestRefIDExclusionList	= LookupID from ValueLookupMaster where [Type] = N'WEBSERVER'	and	[Key] = N'DFBRestRefIDExclusionList'
		
				--Get Customer accounts only
				select		 coalesce(rrid.RID,-1)		'theRestRefID'
							,coalesce(rr.ReferrerID,-1)	'theReferrerID'
							,n.MetroAreaID				'MetroAreaID'
							,res.PartnerID				'PartnerID'
							,c.ConsumerType				'ConsumerType'
							,r.RName					'RName'
							,c.Email					'Email'
							,c.CustID 					'CustID'
							,c.FName 					'FName'
							,c.LName				 	'LName'
							,r.RID						'RID'
							,res.ResID					'ResID'
							,res.LanguageID
							,r.DomainID				
							,res.ShiftDate				'ShiftDate'
							,res.ResTime				'ResTime'
							,res.ResDateTime			'ResDateTime'
							,m.MetroAreaName
							,m.CountryID
							,c.MetroAreaID				'CustHomeMetroID'					
							,0	 						'CallerID'
				from		#ReservationDFF res
				inner join 	RestaurantAVW r 	
					on			r.RID					= res.RID
					and			r.LanguageID			= res.LanguageID
				inner join 	TimeZoneVW tz 
					on			tz.TZID					= r.TZID
				inner join 	Customer c 
					on			c.CustID				= res.CustID
				inner join 	Neighborhood n 
					on			n.NeighborhoodID		= r.NeighborhoodID
				inner join	MetroAreaAVW m
					on			m.MetroAreaID			= n.MetroAreaID
					and			m.LanguageID			= res.LanguageID 
					-- do not bother looking at metros with no DFF
					and			m.DFFStartDT			is not null
				inner join  Partner p 
					on			p.PartnerID				= res.PartnerID
				left join 	ReferrerReservationVW rr 
					on			rr.ResID				= res.ResID
				left join 	ReferrerRestaurantReservationVW rrid 
					on			rrid.ResID				= res.ResID
				-- Shift date most be greater than the metro start date

				left join	ValueLookupIDList	vlil1
					on			vlil1.ValueID		= res.PartnerID
					and			vlil1.LookupID		= @DFBPartnerIDExclusionList

				left join	ValueLookupIDList	vlil2
					on			vlil2.ValueID		= rr.ReferrerID
					and			vlil2.LookupID		= @DFBRefIDExclusionList

				left join	ValueLookupIDList	vlil3
					on			vlil3.ValueID		= res.RID
				and			vlil3.LookupID		= @DFBRestIDExclusionList

				left join	ValueLookupIDList	vlil4
					on			vlil4.ValueID		= rrid.RID
					and			vlil4.LookupID		= @DFBRestRefIDExclusionList				
		
				where 		res.ShiftDate			>= m.DFFStartDT
					-- Apply the email gap hours between the local time @ restaurant and the reso date
				and			res.ResDateTime			< DATEADD(hour, -@EmailGapHours, tz.CurrentLocalTime)
				-- Only send to users that are opt-in
				and			c.DiningFormEmailOptIn	= 1

				-- Check Black List conditions
				and			vlil1.ValueID is null
				and			vlil2.ValueID is null
				and			vlil3.ValueID is null
				and			vlil4.ValueID is null
		
				UNION ALL
		
				--Get the same data for Admin accounts only
				select		 coalesce(rrid.RID,-1)		'theRestRefID'
							,coalesce(rr.ReferrerID,-1)	'theReferrerID'
							,n.MetroAreaID				'MetroAreaID'
							,res.PartnerID				'PartnerID'
							,call.ConsumerType 			'ConsumerType'
							,r.RName					'RName'
							,call.Email 				'Email'
							,cc.CustID 					'CustID'
							,call.FName 				'FName'
							,call.LName 				'LName'
							,r.RID						'RID'
							,res.ResID					'ResID'
							,res.LanguageID
							,r.DomainID				
							,res.ShiftDate				'ShiftDate'
							,res.ResTime				'ResTime'
							,res.ResDateTime			'ResDateTime'
							,m.MetroAreaName
							,m.CountryID
							,call.MetroAreaID	'CustHomeMetroID'					
							,res.CallerID
				from		#ReservationDFF res
				inner join 	RestaurantAVW r 	
					on			r.RID					= res.RID
					and			r.LanguageID			= res.LanguageID
				inner join 	TimeZoneVW tz 
					on			tz.TZID					= r.TZID		
				inner join 	Neighborhood n 
					on			n.NeighborhoodID		= r.NeighborhoodID
				inner join	MetroAreaAVW m
					on			m.MetroAreaID			= n.MetroAreaID
					and			m.LanguageID			= res.LanguageID 
					-- do not bother looking at metros with no DFF
					and			m.DFFStartDT			is not null
				inner join 	Partner p 
					on			p.PartnerID				= res.PartnerID
					left join 	ReferrerReservationVW rr 
					on			rr.ResID				= res.ResID
				left join 	ReferrerRestaurantReservationVW rrid 
					on			rrid.ResID				= res.ResID
				-- Shift date most be greater than the metro start date

				left join	ValueLookupIDList	vlil1
					on			vlil1.ValueID		= res.PartnerID
					and			vlil1.LookupID		= @DFBPartnerIDExclusionList

				left join	ValueLookupIDList	vlil2
					on			vlil2.ValueID		= rr.ReferrerID
					and			vlil2.LookupID		= @DFBRefIDExclusionList

				left join	ValueLookupIDList	vlil3
					on			vlil3.ValueID		= res.RID
					and			vlil3.LookupID		= @DFBRestIDExclusionList

				left join	ValueLookupIDList	vlil4
					on			vlil4.ValueID		= rrid.RID
					and			vlil4.LookupID		= @DFBRestRefIDExclusionList
		
				inner join	Caller	call
					on			res.CallerID		= call.CallerID		
		
				inner join 	CallerCustomer cc
					on			res.CallerID 		= cc.CallerID 
					and 		cc.IsAdmin 			= 1 --join only to the Admin diner to get the Admin's CustID
		
				where 		res.ShiftDate			>= m.DFFStartDT
				-- Apply the email gap hours between the local time @ restaurant and the reso date
				and			res.ResDateTime			< DATEADD(hour, -@EmailGapHours, tz.CurrentLocalTime)
				-- Only send to users that are opt-in
				and			call.DiningFormEmailOptIn	= 1 -- Get only Admins who have opted in to DFF
				and			call.PositionID = 3 -- Get only Admin caller types, not Concierges
				-- Check Black List conditions
				and			vlil1.ValueID is null
				and			vlil2.ValueID is null
				and			vlil3.ValueID is null
				and			vlil4.ValueID is null

				order by	res.ResDateTime		
		
				select @error = @@error
				if @error != 0 goto ErrBlock
		
		END
	
ErrBlock:
	if object_id('tempdb..#ReservationDFF') is not null  
		drop table #ReservationDFF
	if object_id('tempdb..#Resoselect') is not null
		drop table #resoselect

GO

GRANT EXECUTE ON [procEmailGetDiningFeedback2] TO ExecuteOnlyRole
GO


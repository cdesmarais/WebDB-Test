

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetResosByCustomerID1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetResosByCustomerID1]
GO

CREATE PROCEDURE dbo.Admin_GetResosByCustomerID1

@CustomerID int,
@IsCaller bit,
@ShowingAll bit,
@LastResultID int, -- PER TT 26696 
@PageSize int

AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- set up a Table variable to hold the results
DECLARE @ResultsTable TABLE
(
	ResultID int IDENTITY (1,1) PRIMARY KEY,
	reservation_state_id int,
	resostate nvarchar(20),
	confirmation nvarchar(50),
	Shift_Date datetime,
	hour int,
	minute int,
	Date_Made datetime, --This will store date in restaurant time zone.
	Party_Size int,
	restaurant nvarchar(255),
	Points int,
	reservation_ID int,
	restaurant_ID int,
	ResTime datetime,
	LanguageID int,
    Date_Made_PST datetime --This column has been added so that Date in PST can be converted to JST.
)

if @IsCaller = 0
BEGIN
if @ShowingAll = 0 
   BEGIN
   -- put results in table var to facilitate paging
   INSERT INTO @ResultsTable (	reservation_state_id, resostate, confirmation,
								Shift_Date, hour, minute, Date_Made, Party_Size, restaurant, Points,
								reservation_ID, restaurant_ID, ResTime, LanguageID, Date_Made_PST)
        select		res.RStateID as reservation_state_id
					,ReservationState.RStateName as resostate		-- not looking at no-show here
					,cast(res.ConfNumber as nvarchar(50)) AS confirmation
					,ShiftDate as Shift_Date
					,datepart(hour,ResTime) as hour,
					(datepart(minute,ResTime)) as minute
					,dbo.fTimeConvert (DateMade,4,rvw.TZID) as Date_Made --Convert date from PST(TZID=4) to Restaurant timezone.
					,Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End as Party_Size
					,r.RName as restaurant
					,ResPoints As Points
					,res.ResID as reservation_ID
					,res.RID as restaurant_ID
					,res.ResTime -- new MMC
					,res.LanguageID
                    ,DateMade as Date_Made_PST
        from		Reservation res 
        INNER JOIN	RestaurantLocal r 
        ON			r.RID = res.RID
        and			r.LanguageID = res.LanguageID
        Inner Join	ReservationState 
        on			res.RStateID=ReservationState.RStateID
        Inner Join RestaurantVW rvw
        on          res.RID = rvw.RID
        where		CustID = @CustomerID
        and			res.RStateID  in (select RStateID from
												ReservationState where RStateID not in (3,4,8,9,10)) 
    union 
  	(	select		'0' as reservation_state_id
  					,'Point Adjustment' as resostate
  					,'' as confirmation,
					(cast(DATEPART(m,AdjustmentDate) as nvarchar) + '/' + cast(DATEPART(d,AdjustmentDate) as nvarchar) + '/' + cast(DATEPART(yy,AdjustmentDate) as nvarchar)) as Shift_Date
					,datepart(hour,AdjustmentDate) as hour
					,(datepart(minute,AdjustmentDate)) as minute
					,AdjustmentDate as Date_Made ----Here Time not converted as there is no retaurant associated with it.
					,'' as Party_Size
					,'' as restaurant
					,AdjustmentAmount as Points
					,'' as reservation_ID
					,'' as restaurant_ID
					,'' as ResTime -- MMC
					,'' as LanguageID
                    ,AdjustmentDate as Date_Made_PST
		from		PointsAdjustment 
		inner join	PointsAdjustmentReason 
		on			PointsAdjustmentReason.AdjReasonID = PointsAdjustment.AdjReasonID 
		where		CustID = @CustomerID 
	) 
    union -- added Registration points MMC 1/8/08
  	(	select		'0' as reservation_state_id
  					,'Registration' as resostate
  					,'' as confirmation
					,(cast(DATEPART(m,ISNULL(ctcl.ConvertDate, Customer.CreateDate)) as nvarchar) + '/' + cast(DATEPART(d,ISNULL(ctcl.ConvertDate, Customer.CreateDate)) as nvarchar) + '/' + cast(DATEPART(yy,ISNULL(ctcl.ConvertDate, Customer.CreateDate)) as nvarchar)) as Shift_Date
					,datepart(hour,ISNULL(ctcl.ConvertDate, Customer.CreateDate)) as hour,(datepart(minute,ISNULL(ctcl.ConvertDate, Customer.CreateDate))) as minute
					,ISNULL(ctcl.ConvertDate, Customer.CreateDate) as Date_Made
					,'' as Party_Size
					,'' as restaurant
					,PromoUse.Points as Points
					,'' as reservation_ID
					,'' as restaurant_ID
					,-2 as ResTime -- use small res time so that registration time is earlier than any reso time MMC
					,'' as LanguageID
                    ,ISNULL(ctcl.ConvertDate, Customer.CreateDate) as Date_Made_PST
		from		PromoUse 
			INNER JOIN Customer 
					   ON Customer.CustID = @CustomerID
			LEFT OUTER JOIN ConsumerTypeConvertLog ctcl 
						ON ctcl.CustID = Customer.CustID AND
						   ctcl.OriginalConsumerTypeID = 8 -- Anon-to-Registered User
		where		PromoUse.CustID = @CustomerID AND
					PromoUse.PromoID = 1 -- Registration 	
	) 

	order by Shift_Date desc, ResTime desc -- added ResTime per bug 14145 MMC
    END

if @ShowingAll = 1 
   BEGIN
   -- put results in table var to facilitate paging
   INSERT INTO @ResultsTable (	reservation_state_id, resostate, confirmation,
								Shift_Date, hour, minute, Date_Made, Party_Size, restaurant, Points,
								reservation_ID, restaurant_ID, ResTime, LanguageID, Date_Made_PST)

        select		res.RStateID as reservation_state_id,
					case when res.rstateid = 4 
							and ans.resid is not null
						then 'Assumed No Show'
						else ReservationState.RStateName end as resostate,
					cast(res.ConfNumber as nvarchar(50)) AS confirmation,
					ShiftDate as Shift_Date,
					datepart(hour,ResTime) as hour,
					(datepart(minute,ResTime)) as minute,
					dbo.fTimeConvert (DateMade,4,rvw.TZID) as Date_Made,
					Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End as Party_Size,
					r.RName as restaurant,
					ResPoints As Points,
					res.ResID as reservation_ID,
					res.RID as restaurant_ID,
					res.ResTime -- new MMC
					,res.LanguageID
                    ,DateMade as Date_Made_PST
        from		Reservation res 
        INNER JOIN	RestaurantLocal r 
        ON			r.RID = res.RID
        and			r.LanguageID = res.LanguageID
        Inner Join	ReservationState 
        on			res.RStateID=ReservationState.RStateID
        Inner Join RestaurantVW rvw
        on          res.RID = rvw.RID
        left join	ResoErbAssumedNoShow ans		
        on			ans.resid = res.resid
        and			res.rstateid = 4					-- log file is only relevant if res status is assumed no show
        where		CustID = @CustomerID
 	union 
	(
		select		'0' as reservation_state_id,
					'Redemption' as ActivityType,
					Gift.GiftName as confirmation,
					(cast(DATEPART(m,RedemptionDate) as nvarchar) + '/' + cast(DATEPART(d,RedemptionDate) as nvarchar) + '/' + cast(DATEPART(yy,RedemptionDate) as nvarchar)) as Shift_Date,
					datepart(hour,RedemptionDate) as hour,
					(datepart(minute,RedemptionDate)) as minute,
					RedemptionDate as Date_Made,
					'' as Party_Size,
					'' as restaurant,
					PointsRedeemed as Points,
					'' as reservation_ID,
					'' as restaurant_ID,
					'' as ResTime -- MMC
					,'' as LanguageID
                    ,RedemptionDate as Date_Made_PST
		from		GiftRedemption 
		inner join	Gift 
		on			Gift.GiftID = GiftRedemption.GiftID 
		where		CustID = @CustomerID 
	) 
     union 
	(
		select		'0' as reservation_state_id,
					'Point Adjustment' as resostate,
					'' as confirmation,
					(cast(DATEPART(m,AdjustmentDate) as nvarchar) + '/' + cast(DATEPART(d,AdjustmentDate) as nvarchar) + '/' + cast(DATEPART(yy,AdjustmentDate) as nvarchar)) as Shift_Date,
					datepart(hour,AdjustmentDate) as hour,
					(datepart(minute,AdjustmentDate)) as minute,
					AdjustmentDate as Date_Made,
					'' as Party_Size,
					'' as restaurant,
					AdjustmentAmount as Points,
					'' as reservation_ID,
					'' as restaurant_ID,
					'' as ResTime -- MMC
					,'' as LanguageID
                    ,AdjustmentDate as Date_Made_PST
        from		PointsAdjustment 
		inner join	PointsAdjustmentReason on PointsAdjustmentReason.AdjReasonID = PointsAdjustment.AdjReasonID 
		where		CustID = @CustomerID
	) 
    union -- added Registration points MMC 1/8/08
  	(	select		'0' as reservation_state_id
  					,'Registration' as resostate
  					,'' as confirmation
					,(cast(DATEPART(m,ISNULL(ctcl.ConvertDate, Customer.CreateDate)) as nvarchar) + '/' + cast(DATEPART(d,ISNULL(ctcl.ConvertDate, Customer.CreateDate)) as nvarchar) + '/' + cast(DATEPART(yy,ISNULL(ctcl.ConvertDate, Customer.CreateDate)) as nvarchar)) as Shift_Date
					,datepart(hour,ISNULL(ctcl.ConvertDate, Customer.CreateDate)) as hour
					,(datepart(minute,ISNULL(ctcl.ConvertDate, Customer.CreateDate))) as minute
					,ISNULL(ctcl.ConvertDate, Customer.CreateDate) as Shift_Date --Date_Made
					,'' as Party_Size
					,'' as restaurant
					,PromoUse.Points
					,'' as reservation_ID
					,'' as restaurant_ID
					,-2 as ResTime -- use small res time so that registration time is earlier than any reso time MMC
					,'' as LanguageID
                    ,ISNULL(ctcl.ConvertDate, Customer.CreateDate) as Date_Made_PST
		from		PromoUse 
			INNER JOIN Customer ON Customer.CustID = @CustomerID
			LEFT OUTER JOIN ConsumerTypeConvertLog ctcl 
						ON ctcl.CustID = Customer.CustID AND
						   ctcl.OriginalConsumerTypeID = 8 -- Anon-to-Registered User
		where		PromoUse.CustID = @CustomerID AND
					PromoUse.PromoID = 1 -- Registration
	) 
	order by Shift_Date desc, ResTime desc -- added ResTime per bug 14145 MMC
    END

	-- Use RowCount to set the page size
	SET ROWCOUNT @PageSize
	-- do the actual select to return the data
	SELECT	
		*
		-- Convert Date_Made column from PST to JST
		,dbo.fTimeConvert (Date_Made_PST,4,27)as Date_Made_JST
	FROM	@ResultsTable
	WHERE	ResultID > @LastResultID

	-- restore RowCount
	SET ROWCOUNT 0

Return(0)
END	

if @IsCaller = 1
BEGIN
if @ShowingAll = 0 
   BEGIN
    -- put results in table var to facilitate paging
   INSERT INTO @ResultsTable (	reservation_state_id, resostate, confirmation,
								Shift_Date, hour, minute, Date_Made, Party_Size, restaurant, Points,
								reservation_ID, restaurant_ID, ResTime, LanguageID, Date_Made_PST)
       select		res.RStateID as reservation_state_id,
					ReservationState.RStateName as resostate,			-- not looking at no show
					cast(res.ConfNumber as nvarchar(50)) AS confirmation,
					ShiftDate as Shift_Date,
					datepart(hour,ResTime) as hour,
					(datepart(minute,ResTime)) as minute,
					dbo.fTimeConvert (DateMade,4,rvw.TZID) as Date_Made,Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End as Party_Size,
					r.RName as restaurant,
					ResPoints As Points,
					res.ResID as reservation_ID,
					res.RID as restaurant_ID,
					res.ResTime -- new MMC
					,res.LanguageID
                    ,DateMade as Date_Made_PST
        from		Reservation res 
        INNER JOIN	RestaurantLocal r 
        ON			r.RID = res.RID
        and			r.LanguageID = res.LanguageID
        Inner Join	ReservationState on res.RStateID=ReservationState.RStateID
        Inner Join RestaurantVW rvw
        on          res.RID = rvw.RID
        where		res.CallerID = @CustomerID
        and			res.RStateID in (select RStateID from
											ReservationState where RStateID not in (3,4,8,9,10)) 
      union 
	(
		select		'0' as reservation_state_id,
					'Point Adjustment' as resostate,
					'' as confirmation,
					(cast(DATEPART(m,AdjustmentDate) as nvarchar) + '/' + cast(DATEPART(d,AdjustmentDate) as nvarchar) + '/' + cast(DATEPART(yy,AdjustmentDate) as nvarchar)) as Shift_Date,
					datepart(hour,AdjustmentDate) as hour,
					(datepart(minute,AdjustmentDate)) as minute,
					AdjustmentDate as Date_Made,
					'' as Party_Size,
					'' as restaurant,
					AdjustmentAmount as Points,
					'' as reservation_ID,
					'' as restaurant_ID,
					'' as ResTime -- MMC
					,'' as LanguageID
                    ,AdjustmentDate as Date_Made_PST
		from		PointsAdjustment 
		inner join	PointsAdjustmentReason 
		on			PointsAdjustmentReason.AdjReasonID = PointsAdjustment.AdjReasonID 
		where		CallerID = @CustomerID 
	) 
    union -- added Registration points MMC 1/8/08
  	(	select		'0' as reservation_state_id
  					,'Registration' as resostate
  					,'' as confirmation
					,(cast(DATEPART(m,ISNULL(ctcl.ConvertDate, Caller.CreateDate)) as nvarchar) + '/' + cast(DATEPART(d,ISNULL(ctcl.ConvertDate, Caller.CreateDate)) as nvarchar) + '/' + cast(DATEPART(yy,ISNULL(ctcl.ConvertDate, Caller.CreateDate)) as nvarchar)) as Shift_Date
					,datepart(hour,ISNULL(ctcl.ConvertDate, Caller.CreateDate)) as hour,(datepart(minute,ISNULL(ctcl.ConvertDate, Caller.CreateDate))) as minute
					,ISNULL(ctcl.ConvertDate, Caller.CreateDate) as Date_Made
					,'' as Party_Size
					,'' as restaurant
					,PromoUse.Points
					,'' as reservation_ID
					,'' as restaurant_ID
					,-2 as ResTime -- use small res time so that registration time is earlier than any reso time MMC
					,'' as LanguageID
                    ,ISNULL(ctcl.ConvertDate, Caller.CreateDate) as Date_Made_PST
		from		PromoUse 
			INNER JOIN Caller ON Caller.CallerID = @CustomerID
			LEFT OUTER JOIN ConsumerTypeConvertLog ctcl 
						ON ctcl.CallerID = Caller.CallerID AND
						   ctcl.OriginalConsumerTypeID = 8 -- Anon-to-Registered User
		where		PromoUse.CallerID = @CustomerID AND
					PromoUse.PromoID = 1 -- Registration
	) 
	order by Shift_Date desc, ResTime desc -- added ResTime per bug 14145 MMC
    END

if @ShowingAll = 1 
   BEGIN
   -- put results in table var to facilitate paging
   INSERT INTO @ResultsTable (	reservation_state_id, resostate, confirmation,
								Shift_Date, hour, minute, Date_Made, Party_Size, restaurant, Points,
								reservation_ID, restaurant_ID, ResTime, LanguageID, Date_Made_PST)

        select		res.RStateID as reservation_state_id,
					case when res.rstateid = 4 
							and ans.resid is not null
						then 'Assumed No Show'
						else ReservationState.RStateName end as resostate,
					cast(res.ConfNumber as nvarchar(50)) AS confirmation,
					ShiftDate as Shift_Date,
					datepart(hour,ResTime) as hour,
					(datepart(minute,ResTime)) as minute,
					dbo.fTimeConvert (DateMade,4,rvw.TZID) as Date_Made,
					Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End as Party_Size,
					r.RName as restaurant,
					ResPoints As Points,
					res.ResID as reservation_ID,
					res.RID as restaurant_ID,
					res.ResTime -- new MMC
					,res.LanguageID
                    ,DateMade as Date_Made_PST
        from		Reservation res 
        INNER JOIN	RestaurantLocal r 
        ON			r.RID = res.RID
        and			r.LanguageID = res.LanguageID
        Inner Join	ReservationState on res.RStateID=ReservationState.RStateID
        Inner Join RestaurantVW rvw
        on          res.RID = rvw.RID
        left join	ResoErbAssumedNoShow ans
        on			ans.resid = res.resid
        where		res.CallerID = @CustomerID
	union 
	(
		select		'0' as reservation_state_id,
					'Redemption' as ActivityType,
					Gift.GiftName as confirmation,
					(cast(DATEPART(m,RedemptionDate) as nvarchar) + '/' + cast(DATEPART(d,RedemptionDate) as nvarchar) + '/' + cast(DATEPART(yy,RedemptionDate) as nvarchar)) as Shift_Date,
					datepart(hour,RedemptionDate) as hour,
					(datepart(minute,RedemptionDate)) as minute,
					RedemptionDate as Date_Made,
					'' as Party_Size,
					'' as restaurant,
					PointsRedeemed as Points,
					'' as reservation_ID,
					'' as restaurant_ID,
					'' as ResTime -- MMC
					,'' as LanguageID
                    ,RedemptionDate as Date_Made_PST
		from		GiftRedemption 
		inner join	Gift 
		on			Gift.GiftID = GiftRedemption.GiftID 
		where		CallerID = @CustomerID 
) 
    union 
	(
		select		'0' as reservation_state_id,
					'Point Adjustment' as resostate,
					'' as confirmation,
					(cast(DATEPART(m,AdjustmentDate) as nvarchar) + '/' + cast(DATEPART(d,AdjustmentDate) as nvarchar) + '/' + cast(DATEPART(yy,AdjustmentDate) as nvarchar)) as Shift_Date,
					datepart(hour,AdjustmentDate) as hour,
					(datepart(minute,AdjustmentDate)) as minute,
					AdjustmentDate as Date_Made,
					'' as Party_Size,
					'' as restaurant,
					AdjustmentAmount as Points,
					'' as reservation_ID,
					'' as restaurant_ID,
					'' as ResTime -- MMC
					,'' as LanguageID
                    ,AdjustmentDate as Date_Made_PST
		from		PointsAdjustment 
		inner join	PointsAdjustmentReason 
		on			PointsAdjustmentReason.AdjReasonID = PointsAdjustment.AdjReasonID 
		where		CallerID = @CustomerID
	) 
    union -- added Registration points MMC 1/8/08
  	(	select		'0' as reservation_state_id
  					,'Registration' as resostate
  					,'' as confirmation
					,(cast(DATEPART(m,ISNULL(ctcl.ConvertDate, Caller.CreateDate)) as nvarchar) + '/' + cast(DATEPART(d,ISNULL(ctcl.ConvertDate, Caller.CreateDate)) as nvarchar) + '/' + cast(DATEPART(yy,ISNULL(ctcl.ConvertDate, Caller.CreateDate)) as nvarchar)) as Shift_Date
					,datepart(hour,ISNULL(ctcl.ConvertDate, Caller.CreateDate)) as hour,(datepart(minute,ISNULL(ctcl.ConvertDate, Caller.CreateDate))) as minute
					,ISNULL(ctcl.ConvertDate, Caller.CreateDate) as Date_Made
					,'' as Party_Size
					,'' as restaurant
					,PromoUse.Points
					,'' as reservation_ID
					,'' as restaurant_ID
					,-2 as ResTime -- use small res time so that registration time is earlier than any reso time MMC
					,'' as LanguageID
                    ,ISNULL(ctcl.ConvertDate, Caller.CreateDate) as Date_Made_PST
		from		PromoUse 
			INNER JOIN Caller ON Caller.CallerID = @CustomerID
			LEFT OUTER JOIN ConsumerTypeConvertLog ctcl 
						ON ctcl.CallerID = Caller.CallerID AND
						   ctcl.OriginalConsumerTypeID = 8 -- Anon-to-Registered User
		where		PromoUse.CallerID = @CustomerID AND
					PromoUse.PromoID = 1 -- Registration
) 
	order by Shift_Date desc, ResTime desc -- added ResTime per bug 14145 MMC
    END

	-- Use RowCount to set the page size
	SET ROWCOUNT @PageSize
	-- do the actual select to return the data
	SELECT	
		*,
		-- Convert Date_Made PST to JST
		dbo.fTimeConvert (Date_Made_PST,4,27)as Date_Made_JST
	FROM	@ResultsTable
	WHERE	ResultID > @LastResultID

	-- restore RowCount
	SET ROWCOUNT 0

Return(0)
END


GO

GRANT EXECUTE ON [Admin_GetResosByCustomerID1] TO ExecuteOnlyRole

GO


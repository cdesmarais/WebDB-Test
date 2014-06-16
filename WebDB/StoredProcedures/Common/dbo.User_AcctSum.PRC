if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_AcctSum]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_AcctSum]
GO

CREATE PROCEDURE dbo.User_AcctSum
(
    @UserID int,
    @CallerID int,
    @TodayDate datetime,
    @when int = 0
)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Declare @PartnerID int
,@to_date datetime
,@ServerTZID int

if @CallerID = 1

BEGIN
Select @PartnerID = PartnerID 
from Caller 
where CallerID = @UserID

END

Set @to_date = '1/1/1900'
if @PartnerID = '5' or @PartnerID = '16'
BEGIN

Set @to_date = getdate() - 30
END

exec getServerTimeZoneID @retVal = @ServerTZID OUTPUT
if @CallerID = 0
BEGIN

	if @when = 0
	BEGIN
		select 
					 ShiftDate as ActivityDate
					,'Dine' as ActivityType
					,r.RName as ActivityDesc
					,ResPoints as ActivityValue
					,r.RID as EventID
					,Reservation.ResID as ID
		from		 Reservation 
		inner join	 RestaurantVW r 
		on			 r.RID = Reservation.RID 
		where		 CustID = @UserID 
		and			 RStateID in (1) 
		and			 ShiftDate >= @TodayDate
		order by	 ActivityDate desc 
	END

	if @when = 1
	BEGIN
		(select 
					 AdjustmentDate as ActivityDate
					,'Adjustment' as ActivityType
					,PointsAdjustmentReason.Explanation as ActivityDesc
					,AdjustmentAmount as ActivityValue
					,'' as EventID
					,'' as ID
					,'' as Notes
					,'' as Incentive_ID
		from		PointsAdjustment 
		inner join	PointsAdjustmentReason 
		on			PointsAdjustmentReason.AdjReasonID = PointsAdjustment.AdjReasonID 
		where		CustID = @UserID 
		and			PointsAdjustment.AdjReasonID <> 8) 

		union 
		(select RedemptionDate as ActivityDate
		,'Redemption' as ActivityType
		,g.GiftName as ActivityDesc
		,PointsRedeemed as ActivityValue
		,'' as EventID,'' as ID
		,'' as Notes,'' as Incentive_ID
		from GiftRedemption 
		inner join GiftVW g
		on g.GiftID = GiftRedemption.GiftID 
		where CustID = @UserID
		AND PointsRedeemed > 0
			) 

		union 
		(select ShiftDate as ActivityDate
		,'Dine' as ActivityType
		,r.RName as ActivityDesc
		,ResPoints as ActivityValue
		,r.RID as EventID
		,Reservation.ResID as ID
		,Reservation.Notes as Notes
		,incentiveid as Incentive_ID
		from Reservation 
		inner join RestaurantVW r 
		on r.RID = Reservation.RID 
		where CustID = @UserID 
		and RStateID in (2,5,6,7) 
		and ResPoints > 0 ) 
		union 

		(select ShiftDate as ActivityDate
		,'Pending' as ActivityType
		,r.RName as ActivityDesc
		,ResPoints as ActivityValue
		,r.RID as EventID
		,Reservation.ResID as ID
		,Reservation.Notes as Notes
		,incentiveid as Incentive_ID
		from Reservation 
		inner join RestaurantVW r 
		on r.RID = Reservation.RID 
		where CustID = @UserID 
		and RStateID in (1) 
		AND
		/*modified by MH,12/16/02 TT Defect #6550*/
		(DATEADD(Hour,((SELECT _offsetHR FROM TimeZone WHERE TZID = r.TZID)-(SELECT _offsetHR FROM TimeZone WHERE TZID = @ServerTZID)),getDate())) > CAST((CAST(MONTH(ShiftDate) AS nvarchar(2)) + '/' + CAST(DAY(ShiftDate) AS nvarchar(2)) + '/' + CAST(YEAR(ShiftDate) AS nvarchar(4)) + ' ' + CAST(DATEPART(hh,ResTime) AS nvarchar(2)) + ':' + CAST(DATEPART(n,ResTime) AS nvarchar(2)) + ':00') AS datetime)
		)
		union 
		(select ShiftDate as ActivityDate
		,'No Show' as ActivityType
		,r.RName as ActivityDesc
		,0 as ActivityValue
		,r.RID as EventID
		,Reservation.ResID as ID
		,'' as Notes
		,'' as Incentive_ID
		from Reservation 
		inner join RestaurantVW r 
		on r.RID = Reservation.RID 
		where CustID = @UserID 
		and RStateID = 4 
		and ShiftDate <= @TodayDate)
		
		union
		(select RedeemDate as ActivityDate,'Promo' as ActivityType,Promos.PromosDesc as ActivityDesc,PromoUse.points as ActivityValue,'' as EventID,'' as ID,'' as Notes,'' as Incentive_ID
		from PromoUse 
		inner join Promos on Promos.PromoID = PromoUse.PromoID 
		where CustID = @UserID
		and Promos.PromoTypeID <> 2 --Added by DH 11/11/2001
		) 
		order by ActivityDate desc 
	END
END

if @CallerID = 1
BEGIN

	if @when = 0
	BEGIN
		select ShiftDate as ActivityDate,'Dine' as ActivityType,r.RName as ActivityDesc,
		ResPoints as ActivityValue,CallerCustomer.FName,CallerCustomer.LName,r.RID as EventID,Reservation.ResID as ID
		from Reservation 
		inner join RestaurantVW r on r.RID = Reservation.RID 
		inner join CallerCustomer on CallerCustomer.CustID = Reservation.CustID
		where Reservation.CallerID = @UserID and RStateID in (1) and ShiftDate > @TodayDate
		order by ActivityDate desc 
	END

	if @when = 1
	BEGIN
		(select AdjustmentDate as ActivityDate,'Adjustment' as ActivityType,PointsAdjustmentReason.Explanation as ActivityDesc,AdjustmentAmount as ActivityValue,
		'' as First_Name,'' as Last_Name,'' as EventID,'' as ID,'' as Notes,'' as Incentive_ID
		from PointsAdjustment 
		inner join PointsAdjustmentReason on PointsAdjustmentReason.AdjReasonID = PointsAdjustment.AdjReasonID
		where CallerID = @UserID and AdjustmentDate > @to_date and (PointsAdjustment.AdjReasonID <> 8 or AdjustmentAmount < 0)) 
		union 
		(select DonationDate as ActivityDate,'Points Donation' as ActivityType,'' as ActivityDesc,DonationAmount as ActivityValue,
			FName as First_Name,LName as Last_Name,'' as EventID,'' as ID,CompanyName as Notes,'' as Incentive_ID
		from Donations 
		inner join Caller on Donations.CallerFrom = Caller.CallerID
		inner join Company on Caller.CompanyID = Company.CompanyID
		where Charity = @UserID and DonationAmount > 0) 
		union 
		(select RedemptionDate as ActivityDate,'Redemption' as ActivityType, g.GiftName as ActivityDesc, PointsRedeemed as ActivityValue,
		'' as First_Name,'' as Last_Name,'' as EventID,'' as ID,'' as Notes,'' as Incentive_ID
		from GiftRedemption 
		inner join GiftVW g on g.GiftID = GiftRedemption.GiftID 
		where CallerID = @UserID and RedemptionDate > @to_date AND PointsRedeemed > 0 ) 
		union 
		(select ShiftDate as ActivityDate,'Pending' as ActivityType,r.RName as ActivityDesc,
		ResPoints as ActivityValue,CallerCustomer.FName as First_Name,CallerCustomer.LName as Last_Name,r.RID as EventID,Reservation.ResID as ID,Reservation.Notes as Notes,incentiveid as Incentive_ID
		from Reservation 
		inner join RestaurantVW r on r.RID = Reservation.RID 

		inner join CallerCustomer on CallerCustomer.CustID = Reservation.CustID
		where Reservation.CallerID = @UserID and RStateID in (1) AND
		/*modified by MH,12/16/02 TT Defect #6550*/
		(DATEADD(Hour,((SELECT _offsetHR FROM TimeZone WHERE TZID = r.TZID)-(SELECT _offsetHR FROM TimeZone WHERE TZID = @ServerTZID)),getDate())) > CAST((CAST(MONTH(ShiftDate) AS nvarchar(2)) + '/' + CAST(DAY(ShiftDate) AS nvarchar(2)) + '/' + CAST(YEAR(ShiftDate) AS nvarchar(4)) + ' ' + CAST(DATEPART(hh,ResTime) AS nvarchar(2)) + ':' + CAST(DATEPART(n,ResTime) AS nvarchar(2)) + ':00') AS datetime)
		  and ShiftDate > @to_date) 
		union 
		(select ShiftDate as ActivityDate,'Dine' as ActivityType,r.RName as ActivityDesc,
		ResPoints as ActivityValue,CallerCustomer.FName as FName,CallerCustomer.LName as LName,r.RID as EventID,Reservation.ResID as ID,Reservation.Notes as Notes,incentiveid as Incentive_ID
		from Reservation 
		inner join RestaurantVW r on r.RID = Reservation.RID 
		inner join CallerCustomer on CallerCustomer.CustID = Reservation.CustID
		where Reservation.CallerID = @UserID and RStateID in (2,5,6,7) and ShiftDate > @to_date and (ResPoints > 0 or Reservation.CompanyID is not null)) 

		union 
		(select ShiftDate as ActivityDate,'No Show' as ActivityType,r.RName as ActivityDesc,0 as ActivityValue,
		CallerCustomer.FName as FName,CallerCustomer.LName as LName,r.RID as EventID,Reservation.ResID as ID,'' as Notes,'' as Incentive_ID
		from Reservation 
		inner join RestaurantVW r on r.RID = Reservation.RID 
		inner join CallerCustomer on CallerCustomer.CustID = Reservation.CustID
		where Reservation.CallerID = @UserID and RStateID = 4 and ShiftDate <= @TodayDate and ShiftDate > @to_date) 
		union
		(select RedeemDate as ActivityDate,'Promo' as ActivityType,Promos.PromosDesc as ActivityDesc,PromoUse.points as ActivityValue,
		'' as First_Name,'' as Last_Name,'' as EventID,'' as ID,'' as Notes,'' as Incentive_ID

		from PromoUse 
		inner join Promos on Promos.PromoID = PromoUse.PromoID 
		where CallerID = @UserID
		and Promos.PromoTypeID <> 2 -- added by DH 11/11/2001
		 and RedeemDate > @to_date) 
		order by ActivityDate desc 
	END
END
GO

GRANT EXECUTE ON [User_AcctSum] TO ExecuteOnlyRole

GO

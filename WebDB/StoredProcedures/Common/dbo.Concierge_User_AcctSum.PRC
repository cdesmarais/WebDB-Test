if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_User_AcctSum]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_User_AcctSum]
GO

CREATE PROCEDURE dbo.Concierge_User_AcctSum
(
    @UserID int,
    @CallerID int,
    @TodayDate datetime,
    @when int = 0
)
AS
set transaction isolation level read uncommitted

if @CallerID = 0
BEGIN

	if @when = 0
	BEGIN
		select ShiftDate as ActivityDate,'Dine' as ActivityType,r.RName as ActivityDesc,ResPoints as ActivityValue 
		from Reservation 
		inner join RestaurantVW r on r.RID = Reservation.RID 
		where CustID = @UserID and RStateID in (1) and ShiftDate < @TodayDate
		order by ActivityDate asc 
	END

	if @when = 1
	BEGIN
		(select RedemptionDate as ActivityDate,'Redemption' as ActivityType, g.GiftName as ActivityDesc, PointsRedeemed as ActivityValue 
		from GiftRedemption 
		inner join GiftVW g on g.GiftID = GiftRedemption.GiftID 
		where CustID = @UserID) 
		union 
		(select AdjustmentDate as ActivityDate,'Adjustment' as ActivityType,PointsAdjustmentReason.Explanation as ActivityDesc,AdjustmentAmount as ActivityValue 
		from PointsAdjustment 
		inner join PointsAdjustmentReason on PointsAdjustmentReason.AdjReasonID = PointsAdjustment.AdjReasonID 
		where CustID = @UserID) 
		union 
		(select ShiftDate as ActivityDate,'Dine' as ActivityType,r.RName as ActivityDesc,ResPoints as ActivityValue 
		from Reservation 
		inner join RestaurantVW r on r.RID = Reservation.RID 
		where CustID = @UserID and RStateID in (2,5,6,7)) 
		union 
		(select ShiftDate as ActivityDate,'No Show' as ActivityType,r.RName as ActivityDesc,0 as ActivityValue 
		from Reservation 
		inner join RestaurantVW r on r.RID = Reservation.RID 
		where CustID = @UserID and RStateID = 4 and ShiftDate <= @TodayDate) 
		union
		(select RedeemDate as ActivityDate,'Promo' as ActivityType,Promos.PromosDesc as ActivityDesc,PromoUse.points as ActivityValue 
		from PromoUse 
		inner join Promos on Promos.PromoID = PromoUse.PromoID 
		where CustID = @UserID) 
		order by ActivityDate asc 
	END
END

if @CallerID = 1
BEGIN

	if @when = 0
	BEGIN
		select ShiftDate as ActivityDate,'Dine' as ActivityType,r.RName as ActivityDesc,
		ResPoints as ActivityValue,CallerCustomer.FName as First_Name,CallerCustomer.LName as Last_Name
		from Reservation 
		inner join RestaurantVW r on r.RID = Reservation.RID 
		inner join CallerCustomer on CallerCustomer.CustID = Reservation.CustID
		where Reservation.CallerID = @UserID and RStateID in (1) and ShiftDate < @TodayDate and DateMade > '8/12/01'
		order by ActivityDate asc 
	END

	if @when = 1
	BEGIN
		(select RedemptionDate as ActivityDate,'Redemption' as ActivityType,g.GiftName as ActivityDesc,PointsRedeemed as ActivityValue,
		'' as First_Name,'' as Last_Name
		from GiftRedemption 
		inner join GiftVW g on g.GiftID = GiftRedemption.GiftID 
		where CallerID = @UserID and RedemptionDate > '8/12/01') 
		union 
		(select AdjustmentDate as ActivityDate,'Adjustment' as ActivityType,PointsAdjustmentReason.Explanation as ActivityDesc,AdjustmentAmount as ActivityValue,
		'' as First_Name,'' as Last_Name
		from PointsAdjustment 
		inner join PointsAdjustmentReason on PointsAdjustmentReason.AdjReasonID = PointsAdjustment.AdjReasonID
		where CallerID = @UserID) 
		union 
		(select ShiftDate as ActivityDate,'Dine' as ActivityType,r.RName as ActivityDesc,
		ResPoints as ActivityValue,CallerCustomer.FName as First_Name,CallerCustomer.LName as Last_Name
		from Reservation 
		inner join RestaurantVW r on r.RID = Reservation.RID 
		inner join CallerCustomer on CallerCustomer.CustID = Reservation.CustID
		where Reservation.CallerID = @UserID and RStateID in (2,5,6,7) and DateMade > '8/12/01') 
		union 
		(select ShiftDate as ActivityDate,'No Show' as ActivityType,r.RName as ActivityDesc,0 as ActivityValue,
		'' as First_Name,'' as Last_Name
		from Reservation 
		inner join RestaurantVW r on r.RID = Reservation.RID 
		where CallerID = @UserID and RStateID = 4 and ShiftDate <= @TodayDate and DateMade > '8/12/01') 
		union
		(select RedeemDate as ActivityDate,'Promo' as ActivityType,Promos.PromosDesc as ActivityDesc,PromoUse.points as ActivityValue,
		'' as First_Name,'' as Last_Name

		from PromoUse 
		inner join Promos on Promos.PromoID = PromoUse.PromoID 
		where CallerID = @UserID) 
		order by ActivityDate asc 
	END
END

GO

GRANT EXECUTE ON [Concierge_User_AcctSum] TO ExecuteOnlyRole

GO

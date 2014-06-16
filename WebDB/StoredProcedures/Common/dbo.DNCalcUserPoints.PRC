if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCalcUserPoints]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCalcUserPoints]
GO


CREATE PROCEDURE dbo.DNCalcUserPoints
(
    @CallerID int,
    @CustID int,
    @Points int output
)

AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON
set @Points = null

-- Querry is Broken into two parts customer and Caller for Performance Reasons
if @CustID is not null
begin
select @Points = sum(Points)
    from
    (
        (
        select     	-1*sum(Coalesce(PointsRedeemed,0)) 	Points
		from       GiftRedemption 
        where (custId = @CustID)
        )
        union all
        (
        select sum(Coalesce(AdjustmentAmount,0)) Points
		from PointsAdjustment 
        where (custId = @CustID)
        )
        union all
        (
        select sum(Coalesce(ResPoints,0)) Points
		from Reservation r
		where r.RStateID in (2,5,6,7)  --Verified as correct.  BJS 1/20/2005
        	and (custId = @CustID)
        )
        union all
		(
        select sum(Coalesce(pu.points,0)) Points
		from PromoUse pu
        inner join promos p
    		on	   p.PromoID = pu.PromoID
        where (custId = @CustID)
		    and p.promotypeid <> 2 
        )
    ) t
end
ELSE
BEGIN
select @Points = sum(Points)
    from
    (
        (
        select     	-1*sum(Coalesce(PointsRedeemed,0)) 	Points
		from       GiftRedemption 
        where (callerid = @CallerID)
        )
        union all
        (
        select sum(Coalesce(AdjustmentAmount,0)) Points
		from PointsAdjustment 
        where (callerid = @CallerID)
        )
        union all
        (
        select sum(Coalesce(ResPoints,0)) Points
		from Reservation r
		where r.RStateID in (2,5,6,7)  --Verified as correct.  BJS 1/20/2005
        	and (callerid = @CallerID)
        )
        union all
		(
        select sum(Coalesce(pu.points,0)) Points
		from PromoUse pu
        inner join promos p
    		on	   p.PromoID = pu.PromoID
        where (callerid = @CallerID)
		    and p.promotypeid <> 2 
        )
    ) t
END


GO



GRANT EXECUTE ON [DNCalcUserPoints] TO ExecuteOnlyRole

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Select_GiftRedemptions]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Select_GiftRedemptions]
GO


CREATE PROCEDURE dbo.Admin_Select_GiftRedemptions
 (
  @Cust_ID int,
  @isCaller int
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
if @isCaller = 0
BEGIN
Select PointsRedeemed as Points_Redeemed,GiftAttributes as Gift_Attributes,RedemptionDate as Redemption_Date 
from GiftRedemption where CustID =  @Cust_ID
order by RedemptionDate desc
END

else
BEGIN
Select PointsRedeemed as Points_Redeemed,GiftAttributes as Gift_Attributes,RedemptionDate as Redemption_Date 
from GiftRedemption where CallerID =  @Cust_ID
order by RedemptionDate desc

END

GO

GRANT EXECUTE ON [Admin_Select_GiftRedemptions] TO ExecuteOnlyRole

GO

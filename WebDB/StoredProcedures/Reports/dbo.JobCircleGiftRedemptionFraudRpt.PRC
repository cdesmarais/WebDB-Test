if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobCircleGiftRedemptionFraudRpt]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobCircleGiftRedemptionFraudRpt]
go


CREATE  PROCEDURE dbo.JobCircleGiftRedemptionFraudRpt
as

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

select		GR.CallerID
			,C.fname
			,C.lname
			,C.loginName
			,GR.Address1
			,GR.Address2
			,GR.City
			,GR.State
			,GR.Zip
			,GR.Country
			,GR.RedemptionDate
			,PointsRedeemed
			,GiftAttributes
from		giftRedemption GR
inner join	caller C
on			GR.callerID =C.callerID
where		CustID is null
and			C.companyID =538

GO

GRANT EXECUTE ON [JobCircleGiftRedemptionFraudRpt] TO ExecuteOnlyRole

GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_Claimed_Gift]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_Claimed_Gift]
GO




CREATE Procedure dbo.User_Claimed_Gift
(
@UserID		int,
@GiftID		int
)
AS
/*revised for new schema 8/5/2003 --JD*/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT CustID as Customer_ID,GiftID as Gift_ID,Address1,Address2,City,State,Zip as Postal_Code,Country,RedemptionDate as Redemption_Date
FROM GiftRedemption
WHERE CustID = @UserID AND
	GiftID = @GiftID

RETURN
GO

GRANT EXECUTE ON [User_Claimed_Gift] TO ExecuteOnlyRole

GO

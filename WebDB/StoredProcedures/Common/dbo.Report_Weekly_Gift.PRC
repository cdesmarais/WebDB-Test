if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_Weekly_Gift]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_Weekly_Gift]
GO

CREATE PROCEDURE dbo.Report_Weekly_Gift

AS

SET NOCOUNT ON
set transaction isolation level read uncommitted


Select coalesce(OTGiftRed.CustID, OTGiftRed.CallerID) as CID
,coalesce(OTCust.FName,OTCall.FName) as fname
,coalesce(OTCust.LName,OTCall.LName) as lname
,coalesce(OTCust.Email,OTCall.Email) as Email
,OTGiftRed.Address1
,coalesce(OTGiftRed.Address2,'') As Address2
,OTGiftRed.city
,OTGiftRed.state
,OTGiftRed.ZIP
,OTGiftRed.country
,OTGiftRed.RedemptionDate
--,OTGift.MetroAreaName
,OTGiftRed.GiftAttributes
,OTGiftRed.PointsRedeemed as PointsForGift
,coalesce(OTCust.Points,OTCall.Points) as PointsRemaining
,'redeemltr' as LetterType
From GiftRedemption OTGiftRed
left join Customer OTCust 
on        OTGiftRed.CustID = OTCust.CustID
left join gift OTGift 
on        OTGiftRed.GiftID = OTGift.GiftID
left join Caller OTCall 
on        OTGiftRed.CallerID = OTCall.CallerID
Where     OTGiftRed.Extracted = 0
AND       OTGiftRed.PointsRedeemed > 0

GO



GRANT EXECUTE ON [Report_Weekly_Gift] TO ExecuteOnlyRole

GO

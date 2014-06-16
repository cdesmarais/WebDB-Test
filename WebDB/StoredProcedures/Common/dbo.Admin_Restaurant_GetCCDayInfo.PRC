if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_GetCCDayInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_GetCCDayInfo]
GO

CREATE PROCEDURE dbo.Admin_Restaurant_GetCCDayInfo
(
  @RID int,
  @BlockedDate datetime
)
AS

Declare @CreditCard int
exec DNGetMessageTypeID 'CreditCard',@CreditCard output


SELECT 
			r.RID AS RestaurantID
			,r.RName AS RestaurantName
			,BlockedDate as BlockedDate
			,DateBlocked as DateBlocked 
			,Coalesce(CreditCardDayVW.Message,'') as Message
			,coalesce(rcm.Message,(select Message 
									from DefaultMessage d
									where d.MessageTypeID = @CreditCard
									and	 d.LanguageID = r.LanguageID
								   )) as CC_Message
			,CreditCardDayVW.PartySize as PartySize, BlockedBy
From		RestaurantVW r
Inner Join	NeighborhoodAVW n 
On			n.neighborhoodid = r.neighborhoodid
and			n.LanguageID = r.LanguageID
inner join	CreditCardDayVW 
on			r.RID = CreditCardDayVW.RID 
left join	RestaurantCustomMessage rcm
on			rcm.RID = r.RID
and			rcm.LanguageID = r.LanguageID
and			rcm.MessageTypeID = @CreditCard  
WHERE		r.rid = @RID 
and			blockedDate = @BlockedDate
GO

GRANT EXECUTE ON [Admin_Restaurant_GetCCDayInfo] TO ExecuteOnlyRole

GO

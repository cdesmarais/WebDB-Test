if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_ListCreditCard]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_ListCreditCard]
GO

CREATE PROCEDURE dbo.Admin_Restaurant_ListCreditCard
 (
  @GeoID int,
  @date datetime
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @CreditCard int
exec DNGetMessageTypeID 'CreditCard',@CreditCard output

print @CreditCard

SELECT 
			r.RID AS RestaurantID
			,r.RName AS RestaurantName
			,BlockedDate as Blocked_Date
			,Coalesce(CreditCardDayVW.Message,'') as Message
			,coalesce(rcm.Message,
						(select Message 
						from DefaultMessage dm
						where MessageTypeID = @CreditCard 
						and dm.LanguageID = r.LanguageID
						)
			) as CC_Message
			,CreditCardDayVW.PartySize as Party_Size
			,r.RSName
From		RestaurantVW r
Inner Join	NeighborhoodAVW n 
On			r.neighborhoodid = n.neighborhoodid
and			n.LanguageID = r.LanguageID
left join	CreditCardDayVW 
on			r.RID = CreditCardDayVW.RID 
and			BlockedDate = @date
left join	RestaurantCustomMessage rcm
on			rcm.RID = r.RID
and			rcm.LanguageID = r.LanguageID
and			rcm.MessageTypeID = @CreditCard  
WHERE		n.metroareaid = @GeoID
group by	r.RID
			,r.LanguageID
			,r.RName
			,BlockedDate
			,CreditCardDayVW.Message
			,rcm.Message
			,CreditCardDayVW.PartySize
			,r.RSName
ORDER BY	r.RSName, r.RName

GO

GRANT EXECUTE ON [Admin_Restaurant_ListCreditCard] TO ExecuteOnlyRole

GO

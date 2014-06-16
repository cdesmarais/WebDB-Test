if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_LargeParty_GetInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_LargeParty_GetInfo]
GO

CREATE PROCEDURE dbo.Admin_LargeParty_GetInfo

@RestaurantID int

 AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @large int
exec DNGetMessageTypeID 'LargeParty',@large output

SELECT DISTINCT 
				AcceptLargeParty as Accept_Large_Party
				,MaxLargePartyID as Max_Large_Party_ID
				,r.MaxOnlineOptionID as Max_Online_Option_ID
				,moo.MaxOnlineOption AS MaxOnlineOption
				,coalesce(rcm.Message, dbo.fGetRestaurantMessage(r.RID, @large)) as Large_Message
				,RName as Name
FROM			RestaurantVW r
left join		RestaurantCustomMessage rcm
	on				r.RID = rcm.RID
	and				r.LanguageID = rcm.LanguageID
	and				rcm.MessageTypeID = @large
LEFT JOIN		MaxOnlineOption moo on moo.MaxOnlineOptionID = r.MaxOnlineOptionID
WHERE			r.RID = @RestaurantID

GO


GRANT EXECUTE ON [Admin_LargeParty_GetInfo] TO ExecuteOnlyRole

GO

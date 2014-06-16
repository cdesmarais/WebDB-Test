if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XML_Restaurant_CheckLargeParty]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XML_Restaurant_CheckLargeParty]
GO

CREATE PROCEDURE dbo.XML_Restaurant_CheckLargeParty

(
@RestaurantID int,
@PartySize int,
@retval int  OUTPUT 
)

AS

set transaction isolation level read uncommitted

if exists  (
	Select RID from Restaurant r
	inner join MaxOnlineOption mxo 
	on r.MaxOnlineOptionID = mxo.MaxOnlineOptionID
	where r.RID = @RestaurantID 
	and r.AcceptLargeParty = 1 
	and @PartySize > mxo.MaxValue
	)

Select @retval =  (Select MaxOnlineOptionID from Restaurant r
					where r.RID = @RestaurantID)
Else
	Select @retval = 0
	
GO

GRANT EXECUTE ON [XML_Restaurant_CheckLargeParty] TO ExecuteOnlyRole

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_Check_LargeParty]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_Check_LargeParty]
GO

CREATE PROCEDURE dbo.Restaurant_Check_LargeParty

(
@RestaurantID int,
@PartySize int,
@retval int  OUTPUT 
)

 AS
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
 
if exists  (
	Select RID 
	from Restaurant r
	inner join MaxOnlineOption mxo 
	on r.MaxOnlineOptionID = mxo.MaxOnlineOptionID
	where r.RID = @RestaurantID 
	and r.AcceptLargeParty = 1 
	and @PartySize > mxo.MaxValue
	)

Select @retval = 1
Else
Select @retval = 0

GO

GRANT EXECUTE ON [Restaurant_Check_LargeParty] TO ExecuteOnlyRole

GO

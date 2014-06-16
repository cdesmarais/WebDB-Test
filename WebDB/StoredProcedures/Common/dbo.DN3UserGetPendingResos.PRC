if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DN3UserGetPendingResos]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DN3UserGetPendingResos]
GO


CREATE PROCEDURE dbo.DN3UserGetPendingResos
 (
  @UserID int
,@IsCaller int=0
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted
if @IsCaller = 0
BEGIN
Select 
	rest.RName as RestaurantName
	,RStateID as ReservationStateID
	,ShiftDate + 2 + ResTime as ReservationDateTime
	,PartySize as PartySize 
from		Reservation rsv
inner join	RestaurantAVW rest 
on			rest.RID = rsv.RID
and			rest.LanguageID = rsv.LanguageID
where CustID = @UserID 
and RStateID = 1
END
else
BEGIN
Select 
	rest.RName as RestaurantName
	,RStateID as ReservationStateID
	,ShiftDate + 2 + ResTime as ReservationDateTime
	,PartySize as PartySize 
from Reservation rsv
inner join	RestaurantAVW rest
on			rest.RID = rsv.RID
and			rest.LanguageID = rsv.LanguageID
where CallerID = @UserID 
and RStateID = 1
END


GO

GRANT EXECUTE ON [DN3UserGetPendingResos] TO ExecuteOnlyRole

GO

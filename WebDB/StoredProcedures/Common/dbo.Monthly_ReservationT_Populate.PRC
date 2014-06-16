
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Monthly_ReservationT_Populate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Monthly_ReservationT_Populate]
GO



CREATE PROCEDURE dbo.Monthly_ReservationT_Populate

AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

BEGIN TRANSACTION

Delete from ReportReservations

Insert Into ReportReservations
			(ResID,ShiftID,ShiftDate,RStateID,Billable,CallerID,CustID,ResTime,PartySize,DateMade,RID,RName,MetroAreaID,MetroAreaName,NeighborhoodID,NbhoodName,FirstTime,Business,UseDiningCheque,LargeParty,Points,IncentiveID)
(Select
r.ResID,
r.ShiftID,
r.ShiftDate,
r.RStateID,
(Case
when (r.RStateID in(3,4,8,9,10)) then 0 Else 1 End) AS Billable,
r.CallerID,
r.CustID,
r.ResTime,
Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End as PartySize,
r.DateMade,
r.RID,
rts.RName,
ma.MetroAreaID,
ma.MetroAreaName,
n.NeighborhoodID,
n.NbhoodName,
r.FirstTime,
r.Business,
r.UseDiningCheque,
r.LargeParty,
r.ResPoints,
r.IncentiveID
From Reservation r
inner join RestaurantVW rts on r.RID = rts.RID
inner join NeighborhoodAVW n 
on			rts.NeighborhoodID = n.NeighborhoodID
and			rts.languageid = n.languageID
inner join MetroAreaAVW ma 
on			n.MetroAreaID = ma.MetroAreaID
and			rts.languageID = ma.languageID
Where ma.MetroAreaID <> 1)
If @@Error <> 0 goto error

COMMIT TRANSACTION
Return(0)

error:
BEGIN
    ROLLBACK TRANSACTION
    RAISERROR ('Error Inserting Monthly Reservation Information.',17,1)
    RETURN(1)
END


GO


GRANT EXECUTE ON [Monthly_ReservationT_Populate] TO ExecuteOnlyRole

GO

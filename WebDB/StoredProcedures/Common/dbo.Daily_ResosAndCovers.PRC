if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_ResosAndCovers]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_ResosAndCovers]
GO

CREATE PROCEDURE dbo.Daily_ResosAndCovers
(
@strDateOffset int,
@DIPResos bit
)

AS
set transaction isolation level read uncommitted
SET NOCOUNT ON

if @DIPResos = 1
BEGIN
select
(
select count(Reservation.ResID) 
from Reservation
inner join Restaurant 
on Restaurant.RID = Reservation.RID
inner join neighborhood 
on Restaurant.NeighborhoodID = neighborhood.NeighborhoodID 
inner join MetroArea 
on neighborhood.MetroAreaID = MetroArea.MetroAreaID
where 
datediff(d,Reservation.ShiftDate,getdate()-(@strDateOffset+2)) = 0
and Reservation.RStateID in (1,2,5,6,7)
and MetroArea.MetroAreaID <> 1
and Reservation.ResPoints = 1000
)
as ResosTwoDaysAgo,
(
select sum(Case when(Coalesce(SeatedSize,0) < 1) Then PartySize Else SeatedSize End)
from Reservation
inner join Restaurant 
on Restaurant.RID = Reservation.RID
inner join neighborhood 
on Restaurant.NeighborhoodID = neighborhood.NeighborhoodID 
inner join MetroArea 
on neighborhood.MetroAreaID = MetroArea.MetroAreaID
where 
datediff(d,Reservation.ShiftDate,getdate()-(@strDateOffset+2)) = 0
and Reservation.RStateID in (1,2,5,6,7)
and MetroArea.MetroAreaID <> 1
and Reservation.ResPoints = 1000
) as CoversTwoDaysAgo,


(
select count(Reservation.ResID) 
from Reservation
inner join Restaurant 
on Restaurant.RID = Reservation.RID
inner join neighborhood 
on Restaurant.NeighborhoodID = neighborhood.NeighborhoodID 
inner join MetroArea 
on neighborhood.MetroAreaID = MetroArea.MetroAreaID
where 
datediff(m,Reservation.ShiftDate,getdate()-(@strDateOffset+2)) = 0
and Reservation.ShiftDate < getdate()- (@strDateOffset +2)
and Reservation.RStateID in (1,2,5,6,7)
and MetroArea.MetroAreaID <> 1
and Reservation.ResPoints = 1000
) as ResosMonthToDate,
(
select sum(Case when(Coalesce(SeatedSize,0) < 1) Then PartySize Else SeatedSize End)
from Reservation
inner join Restaurant 
on Restaurant.RID = Reservation.RID
inner join neighborhood 
on Restaurant.NeighborhoodID = neighborhood.NeighborhoodID 
inner join MetroArea 
on neighborhood.MetroAreaID = MetroArea.MetroAreaID
where 
datediff(m,Reservation.ShiftDate,getdate()-(@strDateOffset+2)) = 0
and Reservation.ShiftDate < getdate()- (@strDateOffset +2)
and Reservation.RStateID in (1,2,5,6,7)
and MetroArea.MetroAreaID <> 1
and Reservation.ResPoints = 1000
) as CoversMonthToDate


END
else

BEGIN

select
(
select count(Reservation.ResID) 
from Reservation
inner join Restaurant 
on Restaurant.RID = Reservation.RID
inner join neighborhood 
on Restaurant.NeighborhoodID = neighborhood.NeighborhoodID 
inner join MetroArea 
on neighborhood.MetroAreaID = MetroArea.MetroAreaID
where 
datediff(d,Reservation.ShiftDate,getdate()-(@strDateOffset+2)) = 0
and Reservation.RStateID in (1,2,5,6,7)
and MetroArea.MetroAreaID <> 1
--and Reservation.ResPoints = 1000
)
as ResosTwoDaysAgo,
(
select sum(Case when(Coalesce(SeatedSize,0) < 1) Then PartySize Else SeatedSize End)
from Reservation
inner join Restaurant 
on Restaurant.RID = Reservation.RID
inner join neighborhood 
on Restaurant.NeighborhoodID = neighborhood.NeighborhoodID 
inner join MetroArea 
on neighborhood.MetroAreaID = MetroArea.MetroAreaID
where 
datediff(d,Reservation.ShiftDate,getdate()-(@strDateOffset+2)) = 0
and Reservation.RStateID in (1,2,5,6,7)
and MetroArea.MetroAreaID <> 1
--and Reservation.ResPoints = 1000
) as CoversTwoDaysAgo,


(
select count(Reservation.ResID) 
from Reservation
inner join Restaurant 
on Restaurant.RID = Reservation.RID
inner join neighborhood 
on Restaurant.NeighborhoodID = neighborhood.NeighborhoodID 
inner join MetroArea 
on neighborhood.MetroAreaID = MetroArea.MetroAreaID
where 
datediff(m,Reservation.ShiftDate,getdate()-(@strDateOffset+2)) = 0
and Reservation.ShiftDate < getdate()- (@strDateOffset +2)
and Reservation.RStateID in (1,2,5,6,7)
and MetroArea.MetroAreaID <> 1
--and Reservation.ResPoints = 1000
) as ResosMonthToDate,
(
select sum(Case when(Coalesce(SeatedSize,0) < 1) Then PartySize Else SeatedSize End)
from Reservation
inner join Restaurant 
on Restaurant.RID = Reservation.RID
inner join neighborhood 
on Restaurant.NeighborhoodID = neighborhood.NeighborhoodID 
inner join MetroArea 
on neighborhood.MetroAreaID = MetroArea.MetroAreaID
where 
datediff(m,Reservation.ShiftDate,getdate()-(@strDateOffset+2)) = 0
and Reservation.ShiftDate < getdate()- (@strDateOffset +2)
and Reservation.RStateID in (1,2,5,6,7)
and MetroArea.MetroAreaID <> 1
--and Reservation.ResPoints = 1000
) as CoversMonthToDate

END
GO

GRANT EXECUTE ON [Daily_ResosAndCovers] TO ExecuteOnlyRole

GO

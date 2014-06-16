if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_RestaurantResos]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_RestaurantResos]
GO

create proc dbo.Daily_RestaurantResos

@MetroAreaID int

as

set nocount on
set transaction isolation level read uncommitted 

select r.RName as name
,sum((Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End)) as Covers
,left(cast(avg((Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End) * 1.0) as char(10)), 3) as PerResoAverage
,LEFT(cast((sum((Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End)))/ ((CASE(datediff(day, min(rs.DateMade), getDate()))  
                                            WHEN 0 THEN 1 
                                            ELSE (datediff(day, min(rs.DateMade), getDate())) 
                                            END) * 1.00)  as char(20)), 4) as PerDayAvg  
from		restaurantVW r
inner join	reservation rs
on			r.RID = rs.RID
inner join	NeighborhoodAVW n
on			r.NeighborhoodID = n.NeighborhoodID 
and			r.LanguageID = n.LanguageID
where  r.RestStateID = 1 
and  rs.RStateID in (1,2,5,6,7) 
and  n.MetroAreaID =  @MetroAreaID
group by r.RName 
order by Covers desc




GO

GRANT EXECUTE ON [Daily_RestaurantResos] TO ExecuteOnlyRole

GO

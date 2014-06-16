if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_ResoActivity]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_ResoActivity]
GO

CREATE PROCEDURE dbo.Report_ResoActivity

@Date datetime

AS

set transaction isolation level read uncommitted

select		r.RName as Name
			, count(reservation.RID) as reservation_count
			, ' (' + convert(nvarchar(4), sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End)) +  ')' as covers
from		reservation
inner join	restaurantVW r
on			reservation.RID = r.RID
where		datediff(day,reservation.ShiftDate, @Date) = 0
and			reservation.RStateID = 1
group by r.RName
having (count(reservation.RID) between 10 and 19)



/* Part two:  Get info for Restaurants with 20+ resos */
select r.RName as Name
		, r.RID as Restaurant_ID
		, count(reservation.RID) as reservation_count, ' (' + convert(nvarchar(4), sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End)) +  ')' as covers
from		reservation
inner join	restaurantVW r 
on			reservation.RID = r.RID

where		datediff(day,reservation.ShiftDate, @Date) = 0
and			reservation.RStateID = 1
group by	r.RName
			, r.RID
having		(count(reservation.RID) > 19)

GO


GRANT EXECUTE ON [Report_ResoActivity] TO ExecuteOnlyRole

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNHotellResoReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNHotellResoReport]
GO



CREATE PROCEDURE dbo.DNHotellResoReport
(
	@StartDT DateTime,
	@EndDT DateTime,
	@CompanyID int,
	@CallerList varchar(8000), --[EV: List of Int IDs]
	@RIDList varchar(8000) --[EV: List of Int IDs]
)
WITH RECOMPILE
AS


SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--*****************************
--** Retrireves history using RestaurantVW
--** Histroy will only include restaurants in a language supported by the domain / website of the caller
--*****************************

select		res.rid,
			r.Rname,
			IsNull(sum(case when RStateID in (1,2,5,6,7) then 1 else 0 end),0) Seated,
			IsNull(sum(case when RStateID in (1,2,5,6,7) then isnull(SeatedSize, Partysize) else 0 end),0) SeatedCovers,
			IsNull(sum(case when RStateID in (3, 8, 9) then 1 else 0 end),0) Cancellations,
			IsNull(sum(case when RStateID in (4, 10) then 1 else 0 end),0) NoShow,
			cast(IsNull(sum(case when RStateID in (4,10) then 1 else 0 end),0) as float) / cast(count(1) as float) NoShowRate,
			l.LanguageCode as Language
from (
	--****************************
	--** Use a subquery to improve perforamnce with Partitioned Reso Table
	--** NOTE: Query would benifit from an index on ComapnyID and Shiftdate
	--****************************
	select		callerid, 
				rid, 
				rstateid, 
				seatedsize, 
				partysize
	from		Reservation res
	left join	(select id from fIDStrToTab(@CallerList, ',')) cl
	on			res.callerid = cl.id
	left join	(select id from fIDStrToTab(@RIDList, ',')) rl
	on			res.rid = rl.id	
	where		shiftdate >= @startDT and shiftdate < @EndDT + 1
	and			res.CompanyID = @CompanyID
	and			RStateID in (1,2,3,4,5,6,7,8,9,10)
	and			(@CallerList is null or cl.id is not null)  --** If caller list provided then filter based on it
	and			(@RIDList is null or rl.id is not null) --** If RID list provided then filter based on it
) res
INNER JOIN	RestaurantVW r
ON			r.RID = res.RID
inner join	Caller c
on			c.callerid = res.callerid
inner join	Language l
on			l.LanguageID = r.LanguageID
group by	res.rid,
			r.Rname, 
			l.LanguageCode
order by	res.rid

GO


GRANT EXECUTE ON [DNHotellResoReport] TO ExecuteOnlyRole

GO

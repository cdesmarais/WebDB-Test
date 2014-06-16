if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_BizVsPleasure]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_BizVsPleasure]
GO

CREATE proc dbo.Daily_BizVsPleasure 
(
@rptID int
)
as 

set nocount on
set transaction isolation level read uncommitted

declare @PleasureCount int
declare @BusinessCount int
declare @NoAnswer int

SELECT 
	@PleasureCount = coalesce(sum( case when (Business = 2) then 1 else 0 end), 0),
	@BusinessCount = coalesce(sum( case when (Business = 1) then 1 else 0 end), 0),
	@NoAnswer = coalesce(sum(case when (Business is null) then 1 else 0 end), 0)
FROM Reservation r
inner join restaurant rt
on rt.RID = r.RID
inner join neighborhood n
on n.NeighborhoodID = rt.NeighborhoodID 
where r.RStateID in(1,2,5,6,7)
and (r.Business IS NULL or r.Business in (1,2))
and n.MetroAreaID <> 1


declare @strReport as nvarchar(4000)
declare @vbnewline as nvarchar(10)
set @vbnewline = CHAR(13) + CHAR(10)

set @strReport = 'Biz vs. Pleasure vs. No Answer: ' + cast(@BusinessCount as nvarchar(20)) 
	+ '/' + cast(@PleasureCount as nvarchar(20))
	+ '/' + cast(@NoAnswer as nvarchar(20)) + @vbnewline
	
insert into DailyReport (reportid, linenum, txt) values(@rptID, 1, @strReport)
GO


GRANT EXECUTE ON [Daily_BizVsPleasure] TO ExecuteOnlyRole

GO

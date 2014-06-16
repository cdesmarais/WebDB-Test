if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBD_SearchSummaryByMonth]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBD_SearchSummaryByMonth]
GO






CREATE PROCEDURE dbo.DBD_SearchSummaryByMonth
(
@month datetime = null,
@drilldate datetime = null
)
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


if @month is null
BEGIN
Set @month = '1/1/2000'
END
if @drilldate is null
BEGIN
	if @month <> '1/1/2000'
	BEGIN
		Select sum(coalesce(SearchStat,0)) as SearchStat, 
		datePart(dd,dateAdded) as reosdate,datePart(month,dateAdded) as month
		from SearchStatsSummary
		where 
		searchstatTypeID = 11 and datediff(mm,@month,dateAdded) = 0 
		group by datePart(dd,dateAdded),datePart(month,dateAdded) 
		order by datePart(month,dateAdded),datePart(dd,dateAdded) 
	END
else
	BEGIN
		Select sum(coalesce(SearchStat,0)) as SearchStat, 
		datePart(dd,dateAdded) as reosdate,datePart(month,dateAdded) as month
		from SearchStatsSummary
		where 
		searchstatTypeID = 11 and datediff(mm,getdate(),dateAdded) = 0 
		group by datePart(dd,dateAdded),datePart(month,dateAdded) 
		order by datePart(month,dateAdded),datePart(dd,dateAdded) 
	END
END



else
BEGIN
	Select sum(coalesce(SearchStat,0)) as SearchStat, 
	datePart(hh,dateAdded) as datehour
	from SearchStatsSummary
	where 
	searchstatTypeID = 11 and 
	datePart(dd,dateAdded) = datePart(dd,@drilldate) and
	datePart(month,dateAdded) = datePart(month,@drilldate) and
	datePart(year,dateAdded) = datePart(year,@drilldate)
	group by datePart(hh,dateAdded)
	--,datePart(mi,DateMade) 
	order by datePart(hh,dateAdded)

END
GO

GRANT EXECUTE ON [DBD_SearchSummaryByMonth] TO ExecuteOnlyRole

GO

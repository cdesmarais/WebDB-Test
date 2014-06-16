if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Resos_Made_For]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Resos_Made_For]
GO

CREATE PROCEDURE dbo.Admin_Resos_Made_For
(
@month datetime = null,
@drilldate datetime = null
)
 AS
 
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

if @month is null OR @month = '1/1/2000'
BEGIN
Set @month = getdate()
END
if @drilldate is null
BEGIN
	Select SUM(RESO) as resos, SUM(Cover) as Covers, ShiftDay as reosdate,ShiftMonth as month 
	from AGG_DashBoardShiftDateSummary
	where Month(@month) = ShiftMonth
	and Year(@month) = ShiftYear
	group by ShiftDay,ShiftMonth
	order by ShiftDay,ShiftMonth
END

else
BEGIN
	Select RESO as resos, Cover as Covers, ShiftHour as datehour
		from AGG_DashBoardShiftDateSummary
	where ShiftDay = datePart(dd,@drilldate) and
	ShiftMonth = datePart(month,@drilldate) and
	ShiftYear = datePart(year,@drilldate) 
	order by  ShiftHour

END



GO

GRANT EXECUTE ON [Admin_Resos_Made_For] TO ExecuteOnlyRole

GO

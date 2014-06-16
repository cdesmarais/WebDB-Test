if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Resos_Made]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Resos_Made]
GO

CREATE PROCEDURE dbo.Admin_Resos_Made
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
	Select SUM(RESO) as resos, SUM(Cover) as Covers, MadeDay as reosdate,MadeMonth as month 
	from AGG_DashBoardDateMadeSummary 
	where Month(@month) = MadeMonth
	and Year(@month) = MadeYear
	group by MadeDay,MadeMonth
	order by MadeDay,MadeMonth
END

else
BEGIN
Select RESO as resos, Cover as Covers, MadeHour as datehour
	from AGG_DashBoardDateMadeSummary 
where MadeDay = datePart(dd,@drilldate) and
MadeMonth = datePart(month,@drilldate) and
MadeYear = datePart(year,@drilldate) 
order by  MadeHour

END



GO

GRANT EXECUTE ON [Admin_Resos_Made] TO ExecuteOnlyRole

GO

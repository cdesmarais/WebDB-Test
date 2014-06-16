if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobReportGet_AGG_DashBoardDateMadeSummary]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobReportGet_AGG_DashBoardDateMadeSummary]
GO


CREATE PROCEDURE dbo.JobReportGet_AGG_DashBoardDateMadeSummary

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	select 
			count(*) Reso, 
			sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End ) Cover, 
			datepart(hh, DateMade) MadeHour, 
			Day(DateMade) MadeDay, 
			Month(DateMade) MadeMonth, 
			Year(DateMade) MadeYear 
	from Reservation with (nolock)
	where 	ShiftDate >= DateAdd(m, -13, getdate())   	-- for performance
	and		DateMade >= DateAdd(m, -12, getdate()) 	
--			and DateMade < getdate()  					-- not need esp. calling from DayBehind	
	and 	rstateID in (1,2,5,6,7)
	group by datepart(hh, DateMade), 
	Day(DateMade), Month(DateMade), Year(DateMade)

GO

GRANT EXECUTE ON JobReportGet_AGG_DashBoardDateMadeSummary TO DTR_User
GRANT EXECUTE ON JobReportGet_AGG_DashBoardDateMadeSummary TO ExecuteOnlyRole

GO

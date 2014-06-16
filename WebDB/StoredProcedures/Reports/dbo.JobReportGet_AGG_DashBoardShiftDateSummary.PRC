if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobReportGet_AGG_DashBoardShiftDateSummary]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobReportGet_AGG_DashBoardShiftDateSummary]
GO


CREATE PROCEDURE dbo.JobReportGet_AGG_DashBoardShiftDateSummary

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


	select 	
			count(*) Reso, 
			sum(Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End) Cover, 
			datepart(hh, ResTime) ShiftHour,
			Day(ShiftDate) ShiftDay, 
			Month(ShiftDate) ShiftMonth, 
			Year(ShiftDate) ShiftYear 
	from Reservation with (nolock)
	where shiftDate >= DateAdd(m, -6, getdate()) 
			and ShiftDate<= DateAdd(m, 6, getdate())
			and rstateID in (1,2,5,6,7)
	group by datepart(hh, ResTime), Day(ShiftDate), Month(ShiftDate), Year(ShiftDate)


GO

GRANT EXECUTE ON JobReportGet_AGG_DashBoardShiftDateSummary TO DTR_User
GRANT EXECUTE ON JobReportGet_AGG_DashBoardShiftDateSummary TO ExecuteOnlyRole

GO

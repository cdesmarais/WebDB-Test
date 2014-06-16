if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobReportUpdate_AGG_DashBoardShiftDateSummary]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobReportUpdate_AGG_DashBoardShiftDateSummary]
GO


CREATE PROCEDURE dbo.JobReportUpdate_AGG_DashBoardShiftDateSummary

AS


	if (select count(*) from AGG_DashBoardShiftDateSummary_Staging)>0 
	Begin
		
		Begin Transaction
			Delete from AGG_DashBoardShiftDateSummary 

			Insert into AGG_DashBoardShiftDateSummary
			(	[Reso],
				[Cover],
				[ShiftHour],
				[ShiftDay],
				[ShiftMonth],
				[ShiftYear])
			select [Reso],
				[Cover],
				[ShiftHour],
				[ShiftDay],
				[ShiftMonth],
				[ShiftYear]
			from AGG_DashBoardShiftDateSummary_Staging

		if (select count(*) from AGG_DashBoardShiftDateSummary)>0 
				commit Transaction
		else	Rollback Transaction	

	End


GO

GRANT EXECUTE ON JobReportUpdate_AGG_DashBoardShiftDateSummary TO DTR_User
GRANT EXECUTE ON JobReportUpdate_AGG_DashBoardShiftDateSummary TO ExecuteOnlyRole

GO

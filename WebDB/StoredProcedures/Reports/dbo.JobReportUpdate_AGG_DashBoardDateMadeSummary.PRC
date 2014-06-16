if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobReportUpdate_AGG_DashBoardDateMadeSummary]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobReportUpdate_AGG_DashBoardDateMadeSummary]
GO


CREATE PROCEDURE dbo.JobReportUpdate_AGG_DashBoardDateMadeSummary

AS


	if (select count(*) from AGG_DashBoardDateMadeSummary_Staging)>0 
	Begin
		
		Begin Transaction
			Delete from AGG_DashBoardDateMadeSummary 

			Insert into AGG_DashBoardDateMadeSummary
			(	[Reso],
				[Cover],
				[MadeHour],
				[MadeDay],
				[MadeMonth],
				[MadeYear])
			select [Reso],
				[Cover],
				[MadeHour],
				[MadeDay],
				[MadeMonth],
				[MadeYear]
			from AGG_DashBoardDateMadeSummary_Staging

		if (select count(*) from AGG_DashBoardDateMadeSummary)>0 
				commit Transaction
		else	Rollback Transaction	

	End


GO

GRANT EXECUTE ON JobReportUpdate_AGG_DashBoardDateMadeSummary TO DTR_User
GRANT EXECUTE ON JobReportUpdate_AGG_DashBoardDateMadeSummary TO ExecuteOnlyRole

GO

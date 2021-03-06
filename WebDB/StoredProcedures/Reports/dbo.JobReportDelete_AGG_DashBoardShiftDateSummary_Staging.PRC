IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[DBO].[JobReportDelete_AGG_DashBoardShiftDateSummary_Staging]') AND OBJECTPROPERTY(ID, N'ISPROCEDURE') = 1)
	DROP PROCEDURE [dbo].[JobReportDelete_AGG_DashBoardShiftDateSummary_Staging]
GO

CREATE PROCEDURE dbo.JobReportDelete_AGG_DashBoardShiftDateSummary_Staging
AS
BEGIN

	DELETE FROM dbo.AGG_DashBoardShiftDateSummary_Staging

END

GO

GRANT EXECUTE ON [JobReportDelete_AGG_DashBoardShiftDateSummary_Staging] TO DTR_User
GRANT EXECUTE ON [JobReportDelete_AGG_DashBoardShiftDateSummary_Staging] TO ExecuteOnlyRole

GO
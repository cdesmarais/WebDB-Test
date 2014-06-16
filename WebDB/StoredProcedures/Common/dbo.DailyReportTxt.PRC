if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DailyReportTxt]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DailyReportTxt]
GO

CREATE PROCEDURE dbo.DailyReportTxt
AS
set transaction isolation level read uncommitted
SET NOCOUNT ON

select * from dailyReport
where reportID < 9999
order by ReportID,LineNum

GO

GRANT EXECUTE ON [DailyReportTxt] TO ExecuteOnlyRole

GO

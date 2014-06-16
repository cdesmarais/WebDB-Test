
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBD_GetFunnelMetrics]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBD_GetFunnelMetrics]
GO




CREATE PROCEDURE dbo.DBD_GetFunnelMetrics
(
    @MetricDateThisMonth datetime,
    @MetricDateLastMonth datetime,
    @MetricDateLastYear datetime,
    @ReportType int
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- All Metrics
if @ReportType = 1
BEGIN
	Select sum(MetricValue) as metricSum, Metrics.MetricID, MetricDate, MetricName, MetricDescription 
	from Metrics
	inner join  MetricTypes on Metrics.MetricID = MetricTypes.MetricID
	where MetricDate in (@MetricDateThisMonth,@MetricDateLastMonth,@MetricDateLastYear)
	group by Metrics.MetricID, MetricDate, MetricName, MetricDescription 
	order by MetricDate, Metrics.MetricID
END

-- OpenTable.com Only
if @ReportType = 2
BEGIN
	Select sum(MetricValue) as metricSum, Metrics.MetricID, MetricDate, MetricName, MetricDescription 
	from Metrics
	inner join  MetricTypes on Metrics.MetricID = MetricTypes.MetricID
	where MetricDate in (@MetricDateThisMonth,@MetricDateLastMonth,@MetricDateLastYear)
	and PartnerID = 1 and referrerID is null and restrefid is null
	group by Metrics.MetricID, MetricDate, MetricName, MetricDescription 
	order by MetricDate, Metrics.MetricID
END

-- Restaurant Referrals
if @ReportType = 3
BEGIN
	Select sum(MetricValue) as metricSum, Metrics.MetricID, MetricDate, MetricName, MetricDescription 
	from Metrics
	inner join  MetricTypes on Metrics.MetricID = MetricTypes.MetricID
	where MetricDate in (@MetricDateThisMonth,@MetricDateLastMonth,@MetricDateLastYear)
	and PartnerID = 1 and referrerID is null and restrefid is not null	
	group by Metrics.MetricID, MetricDate, MetricName, MetricDescription 
	order by MetricDate, Metrics.MetricID
END

-- Parnter Referrals
if @ReportType = 4
BEGIN
	Select sum(MetricValue) as metricSum, Metrics.MetricID, MetricDate, MetricName, MetricDescription 
	from Metrics
	inner join  MetricTypes on Metrics.MetricID = MetricTypes.MetricID
	where MetricDate in (@MetricDateThisMonth,@MetricDateLastMonth,@MetricDateLastYear)
	and (PartnerID != 1 or referrerID is not null) and restrefid is null	
	group by Metrics.MetricID, MetricDate, MetricName, MetricDescription 
	order by MetricDate, Metrics.MetricID
END
GO

SET ANSI_NULLS ON
GO


GRANT EXECUTE ON [DBD_GetFunnelMetrics] TO ExecuteOnlyRole

GO

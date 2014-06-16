if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobNagiosCheckFutureResoCount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobNagiosCheckFutureResoCount]
GO

CREATE Procedure dbo.JobNagiosCheckFutureResoCount
as

--This proc is called through a SQL Job and raises an error if the count of records in 
--ReservationFuture table exceed a predetermined value. The error is caught by Nagios and 
--is shown under **DataBase Jobs Category in Nagios**

DECLARE	@Threshold INT
DECLARE	@ResoCount INT

SELECT	@Threshold = ValueInt
FROM	ValueLookup
WHERE	LType = 'NAGIOS_ReservationFuture'
AND		LKey = 'CountThreshold'

SELECT	@ResoCount=COUNT(1)
FROM	ReservationFuture WITH (READUNCOMMITTED)

IF	(@ResoCount > ISNULL(@Threshold,10))
	RAISERROR ('Record Count in ReservationFuture Table has passed the threshold!', 16, 1)


GO

GRANT EXECUTE ON [JobNagiosCheckFutureResoCount] TO ExecuteOnlyRole
GO
GRANT EXECUTE ON [JobNagiosCheckFutureResoCount] TO MonitorUser
GO







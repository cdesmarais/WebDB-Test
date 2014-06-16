if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNNagiosGetCancelQueueRatio]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNNagiosGetCancelQueueRatio]
GO





--This proc Gets The Ratio of Failed makes to Successful makes and returns the value to OTMonitoring

CREATE Procedure [dbo].[DNNagiosGetCancelQueueRatio]
As

--This proc Gets The Ratio of Failed makes to Successful makes and returns the value to OTMonitoring

SET		NOCOUNT ON
SET		TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE	@CancelCount	FLOAT
DECLARE	@ResoCount		FLOAT
DECLARE	@CQRate			FLOAT
DECLARE	@CurrTime		DATETIME
DECLARE @Status			TINYINT

SET		@CurrTime=GETDATE()

SELECT	@CancelCount=COUNT(1)
FROM	CancelQueue
WHERE	ResID is NULL
AND		CreateDT BETWEEN DATEADD(mi, -60, @CurrTime) AND @CurrTime


SELECT	@ResoCount=	CASE 
						WHEN	SUM(SearchStat) IS NULL		THEN	1
						WHEN	SUM(SearchStat) = 0			THEN	1
						ELSE	SUM(SearchStat)
					END
FROM	logserver_NA.WebLogDb.dbo.SearchStatsSummary
WHERE	SearchStatTypeID = 9
AND		DateAdded BETWEEN DATEADD(mi, -60, @CurrTime) AND @CurrTime

SET		@CQRate = @CancelCount/@ResoCount

SET		@Status	= CASE 
					WHEN (@CQRate) > 0.05 THEN 2 -- Critical
					WHEN (@CQRate) BETWEEN 0.01 AND 0.05 THEN 1 -- Warning
					ELSE 0
				  END
						
--OT monitor expects the result in following format for Nagios

SELECT		0 AS GroupData,
			NULL AS GroupCount,
			NagiosHost,
			'Cancel Queue Ratio' AS NagiosService,
			0 AS Expired,
			@Status AS Status,
			GETDATE() AS UpdateDT,
			'Cancel Queue Ratio is ' + CAST (CEILING(@CQRate*100) AS VARCHAR(10)) + '%' AS Msg
FROM		NagiosTaskType 
WHERE		Type = 6
GO


GRANT EXECUTE ON [DNNagiosGetCancelQueueRatio] TO ExecuteOnlyRole

GO


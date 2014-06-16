if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AF_NagiosGetCancelQueueRatio]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AF_NagiosGetCancelQueueRatio]
GO



CREATE Procedure [dbo].[AF_NagiosGetCancelQueueRatio]
@CheckID INT
As

SET		NOCOUNT ON
SET		TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE	@CancelCount	FLOAT
DECLARE	@ResoCount		FLOAT
DECLARE	@CQRate			FLOAT
DECLARE	@CurrTime		DATETIME
DECLARE @Status			TINYINT
DECLARE	@MessageDetails	NVARCHAR(300)

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
					ELSE 0
				  END
						

SET			@MessageDetails = 'Cancel Queue Ratio is ' + CAST (CEILING(@CQRate*100) AS VARCHAR(10)) + '%'

EXEC		dbo.AF_NagiosWriteStatus	@CheckID=@CheckID, 
										@Status=@Status, 
										@MessageSummary='Cancel Queue Ratio',
										@MessageDetails=@MessageDetails


GO



GRANT EXECUTE ON [AF_NagiosGetCancelQueueRatio] TO ExecuteOnlyRole
GRANT EXECUTE ON [AF_NagiosGetCancelQueueRatio] TO MonitorUser
GO


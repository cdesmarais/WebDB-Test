

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNNagiosGetERBtoWebResoUpdateRatio]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNNagiosGetERBtoWebResoUpdateRatio]
GO



CREATE Procedure [dbo].[DNNagiosGetERBtoWebResoUpdateRatio]
As

--This proc Gets The Ratio of ERB makes and updates to makes on Web and returns the value to OTMonitoring

SET		NOCOUNT ON
SET		TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE	@UpdateCount	FLOAT
DECLARE	@ResoCount		FLOAT
DECLARE	@CurrTime		DATETIME
DECLARE @Status			TINYINT

SET		@CurrTime=GETDATE()

SELECT	@UpdateCount=ISNULL(SUM(CASE WHEN WLogType BETWEEN 10 AND 14 THEN 1 ELSE 0 END),0),
		@ResoCount=ISNULL(SUM(CASE WHEN WLogType=1 THEN 1 ELSE 0 END),0)
FROM	logserver_NA.WebLogDb.dbo.WLog
WHERE	(WLogType BETWEEN 10 AND 14--ERB Messages
OR		WLogType = 1)--Web Makes
AND		CreateDT BETWEEN DATEADD(mi, -60, @CurrTime) AND @CurrTime

IF		(@Resocount=0)
SET		 @Resocount=1 -- To prevent division by zero


SET		@Status	= CASE 
					WHEN (@UpdateCount/@ResoCount) < 0.5 THEN 2 -- Critical
					WHEN (@UpdateCount/@ResoCount) BETWEEN 0.5 AND 0.9 THEN 1 -- Warning
					ELSE 0
				  END
						
--OT monitor expects the result in following format for Nagios

SELECT		0 AS GroupData,
			NULL AS GroupCount,
			NagiosHost,
			'Reservation Update Ratio' AS NagiosService,
			0 AS Expired,
			@Status AS Status,
			GETDATE() AS UpdateDT,
			'ERB to Web Reso Update Ratio is ' + CAST (CEILING((@UpdateCount/@ResoCount)*100) AS VARCHAR(10)) + '%' AS Msg
FROM		NagiosTaskType 
WHERE		Type = 6

GO

GRANT EXECUTE ON [DNNagiosGetERBtoWebResoUpdateRatio] TO ExecuteOnlyRole

GO


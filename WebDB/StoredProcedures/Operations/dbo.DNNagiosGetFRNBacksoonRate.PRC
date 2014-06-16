if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNNagiosGetFRNBacksoonRate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNNagiosGetFRNBacksoonRate]
GO



CREATE Procedure [dbo].[DNNagiosGetFRNBacksoonRate]
As

--This proc Gets The Rate of FRNBacksoon for Nagios

SET			NOCOUNT ON
SET			TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE		@Uptime					FLOAT
DECLARE		@DownTime				FLOAT
DECLARE		@FalseReserveNow		FLOAT
DECLARE		@Other					FLOAT
DECLARE		@FRNBSRate				FLOAT
DECLARE		@Status					TINYINT

SELECT		@Uptime					= SUM(Case when (r.IsReachable = 1 AND r.RestStateID = 1) then 1 Else 0 End)
			,@DownTime				= SUM(Case when (r.IsReachable = 0 AND r.RestStateID = 1) then 1 Else 0 End)
			,@FalseReserveNow		= SUM(Case when (r.RestStateID = 16) then 1 Else 0 End)
			,@Other					= SUM(Case when (r.RestStateID in (5,6,7,13)) then 1 Else 0 End)
			
FROM		 RestaurantVW r
option		(keepfixed plan)

SET			@FRNBSRate = ((@FalseReserveNow+@DownTime)/(@Uptime + @DownTime + @FalseReserveNow + @Other))

SET		@Status	= CASE 
					WHEN @FRNBSRate > 0.2 THEN 2 -- Critical
					WHEN @FRNBSRate BETWEEN 0.11 AND 0.2 THEN 1 -- Warning
					ELSE 0
				  END
						
--OT monitor expects the result in following format for Nagios

SELECT		0 AS GroupData,
			NULL AS GroupCount,
			NagiosHost,
			'BackSoon FRN' AS NagiosService,
			0 AS Expired,
			@Status AS Status,
			GETDATE() AS UpdateDT,
			'BackSoonFRN Rate is ' + CAST (CEILING(@FRNBSRate*100) AS VARCHAR(10)) + '%' AS Msg
FROM		NagiosTaskType 
WHERE		Type = 6
GO



GRANT EXECUTE ON [DNNagiosGetFRNBacksoonRate] TO ExecuteOnlyRole

GO


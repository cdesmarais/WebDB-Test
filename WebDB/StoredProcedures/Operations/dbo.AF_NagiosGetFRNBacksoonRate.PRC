if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AF_NagiosGetFRNBacksoonRate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AF_NagiosGetFRNBacksoonRate]
GO



CREATE Procedure [dbo].[AF_NagiosGetFRNBacksoonRate]
@CheckID INT
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
DECLARE		@MessageDetails			NVARCHAR(300)

SELECT		@Uptime					= SUM(Case when (r.IsReachable = 1 AND r.RestStateID = 1) then 1 Else 0 End)
			,@DownTime				= SUM(Case when (r.IsReachable = 0 AND r.RestStateID = 1) then 1 Else 0 End)
			,@FalseReserveNow		= SUM(Case when (r.RestStateID = 16) then 1 Else 0 End)
			,@Other					= SUM(Case when (r.RestStateID in (5,6,7,13)) then 1 Else 0 End)
			
FROM		 RestaurantVW r
OPTION		(KEEPFIXED PLAN)

SET			@FRNBSRate = ((@FalseReserveNow+@DownTime)/(@Uptime + @DownTime + @FalseReserveNow + @Other))

	SET		@Status	= CASE 
						WHEN @FRNBSRate > 0.2 THEN 2 -- Critical
						ELSE 0
					  END
						
SET			@MessageDetails = 'BackSoonFRN Rate is ' + CAST (CEILING(@FRNBSRate*100) AS VARCHAR(10)) + '%'

EXEC		dbo.AF_NagiosWriteStatus	@CheckID=@CheckID, 
										@Status=@Status, 
										@MessageSummary='BackSoon FRN',
										@MessageDetails=@MessageDetails


GO



GRANT EXECUTE ON [AF_NagiosGetFRNBacksoonRate] TO ExecuteOnlyRole
GRANT EXECUTE ON [AF_NagiosGetFRNBacksoonRate] TO MonitorUser
GO


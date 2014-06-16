if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNNagiosArePassiveChecksWorking]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNNagiosArePassiveChecksWorking]
GO




CREATE Procedure [dbo].[DNNagiosArePassiveChecksWorking]
As

--This proc always returns Successful to Nagios when OTMonitoring service is running. 
--The purpose of this proc is to detect failure of all Passive Checks which is often caused when the OTMonitoring service hangs. 

SET		NOCOUNT ON
SET		TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


--OT monitor expects the result in following format for Nagios

SELECT		0 AS GroupData,
			NULL AS GroupCount,
			NagiosHost,
			'Passive Checks Monitor' AS NagiosService,
			0 AS Expired,
			0 AS Status,
			GETDATE() AS UpdateDT,
			'Passive checks are working!' AS Msg
FROM		NagiosTaskType 
WHERE		Type = 6
GO


GRANT EXECUTE ON [DNNagiosArePassiveChecksWorking] TO ExecuteOnlyRole

GO


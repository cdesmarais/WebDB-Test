if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetGeneralLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetGeneralLog]
GO

CREATE PROCEDURE dbo.DNGetGeneralLog
(
	@nSeverityLevel int
)
 AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

if @nSeverityLevel = 3
Select * from LogLowSeverity
if @nSeverityLevel = 2
Select * from LogMediumSeverity
if @nSeverityLevel = 1
Select * from LogHighSeverity
	
GO



GRANT EXECUTE ON [DNGetGeneralLog] TO ExecuteOnlyRole

GO

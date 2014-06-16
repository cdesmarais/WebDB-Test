if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procNagiosActiveResponse]') 
and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procNagiosActiveResponse]
GO

create Procedure [dbo].[procNagiosActiveResponse]
(
    @Status     INT,        
    @Message    varchar(1000)
)
As

SET            NOCOUNT ON
SET            TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE         @NagiosZeroStatusMessage    INT
select          @NagiosZeroStatusMessage    = ValueInt
from            valuelookup
where           LType                        = 'NAGIOS'
and             Lkey                        = 'ZeroStatusMessage'

select          @NagiosZeroStatusMessage    = coalesce(@NagiosZeroStatusMessage, 0)


--** Output Status and message
--** Note Currently a bug in nagios; success must only be 0 (no message)
select  @Status                                                                 as Status,
        (case   when @Status = 0 and @NagiosZeroStatusMessage = 0 then '' 
                else replace(@Message, ' ', '_') 
                end)                                                            as ErrorMessage

GO

GRANT EXECUTE ON [procNagiosActiveResponse] TO ExecuteOnlyRole
GRANT EXECUTE ON [procNagiosActiveResponse] TO MonitorUser

GO


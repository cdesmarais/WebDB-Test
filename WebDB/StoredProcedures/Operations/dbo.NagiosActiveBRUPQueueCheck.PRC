if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[NagiosActiveBRUPQueueCheck]') 
and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[NagiosActiveBRUPQueueCheck]
GO

CREATE Procedure [dbo].[NagiosActiveBRUPQueueCheck]
As

-- 
-- This proc is used to generate a Nagios alert/warning 
-- if the age of unprocessed BRUP Queue exceeds a configurable threshold.
-- If the BRUP Queue Age exceeds the critical level (BRUP_Queue_Age_MI_Critical, above default value is 300),
-- then a Nagios alert is generated (Status = 2)
-- If the BRUP Queue Age is not critical but exceeds the warning level (BRUP_Queue_Age_MI_Warning, default value is 180)
-- then a Nagios warning is produced (Status = 1).
-- 

SET        NOCOUNT ON
SET        TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE    @BRUPQueue_Age_MI		             INT
DECLARE    @BRUPQueue_Age_MI_Critical   INT
DECLARE    @BRUPQueue_Age_MI_Warning    INT
DECLARE    @Status						TINYINT
DECLARE    @Message						VARCHAR(100)

select     @BRUPQueue_Age_MI_Critical   = ValueInt
from       valuelookup
where      LType						 = 'NAGIOS'
and        Lkey							 = 'BRUP_Queue_Age_MI_Critical'

select     @BRUPQueue_Age_MI_Critical	 = coalesce(@BRUPQueue_Age_MI_Critical, 300)

select     @BRUPQueue_Age_MI_Warning    = ValueInt
from       valuelookup
where      LType						= 'NAGIOS'
and        Lkey							= 'BRUP_Queue_Age_MI_Warning'

select     @BRUPQueue_Age_MI_Warning    = coalesce(@BRUPQueue_Age_MI_Warning, 180)

SELECT     @BRUPQueue_Age_MI			= DATEDIFF(mi,MIN(createdt),GETDATE())
FROM       BRUPQueue					b
LEFT JOIN  BRUPQueueProcessed			bp
ON         b.BRUPQueueID				= bp.BRUPQueueID
where      IsNull(Processed,0)			!= 1 -- Do not include processed messages

SET        @Status= CASE 
                     WHEN @BRUPQueue_Age_MI > @BRUPQueue_Age_MI_Critical									 THEN 2 -- Critical
                     WHEN @BRUPQueue_Age_MI BETWEEN @BRUPQueue_Age_MI_Warning AND @BRUPQueue_Age_MI_Critical THEN 1 -- Warning
                     ELSE																					      0 -- Normal
                    END

SET        @Message = 'The BRUPQueue_Age_MI is ' 
                    + CAST (@BRUPQueue_Age_MI AS VARCHAR(10)) 
                    + ' at time: ' 
                    + convert(varchar(30), getdate(), 109)


exec procNagiosActiveResponse @Status, @Message
GO

GRANT EXECUTE ON [NagiosActiveBRUPQueueCheck] TO ExecuteOnlyRole
GRANT EXECUTE ON [NagiosActiveBRUPQueueCheck] TO MonitorUser

GO


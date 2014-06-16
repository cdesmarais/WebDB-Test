-- If the procedure exists, drop it first
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobResLogMessagePurge]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobResLogMessagePurge]
GO

-- Create the procedure
CREATE PROCEDURE dbo.[JobResLogMessagePurge]
AS

-- Turns off messages SQL Server sends back to the client
SET NOCOUNT ON

DECLARE @NoOfDaysToLookBack INT
DECLARE @ErrMsg NVARCHAR(500)

SET @NoOfDaysToLookBack = 180 -- ResLog_SentMessage's reservation data older than 6 months

-- Delete messages from ResLog_SentMessage whose corresponding reservations that are older than 180 days
DELETE rsm FROM dbo.ResLog_SentMessage rsm
INNER JOIN dbo.ReservationLog rl WITH (NOLOCK) ON rsm.ResLogID = rl.ResLogID
WHERE rl.ShiftDT < (GETDATE() - @NoOfDaysToLookBack)

-- Delete messages from ResLog_FailedMessage whose corresponding reservations that are older than 180 days
DELETE rfm FROM dbo.ResLog_FailedMessage rfm
INNER JOIN dbo.ReservationLog rl WITH (NOLOCK) ON rfm.ResLogID = rl.ResLogID
WHERE rl.ShiftDT < (GETDATE() - @NoOfDaysToLookBack)

-- Delete messages from ResLog_IgnoredMessage whose corresponding reservations that are older than 180 days
DELETE rim FROM dbo.ResLog_IgnoredMessage rim
INNER JOIN dbo.ReservationLog rl WITH (NOLOCK) ON rim.ResLogID = rl.ResLogID
WHERE rl.ShiftDT < (GETDATE() - @NoOfDaysToLookBack)

IF @@ERROR <> 0
BEGIN
	SET @ErrMsg = 'dbo.JobResLogMessagePurge: Error purging ResLog_SentMessage table.- ' + ERROR_MESSAGE()
	RAISERROR(@ErrMsg, 16, 1)			
END

GO

GRANT EXECUTE ON [JobResLogMessagePurge] TO ExecuteOnlyRole

GO



-- If the procedure exists, drop it first
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_UpdateResLogFailedMessage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_UpdateResLogFailedMessage]
GO

-- Create the procedure
CREATE PROCEDURE dbo.[Admin_UpdateResLogFailedMessage]
@ResLogID INT,
@MessageType INT,
@RetryCount INT,
@ResLogErrorTypeID INT
AS

-- Turns off messages SQL Server sends back to the client
SET NOCOUNT ON

-- Update ResLogg_FailedMessage table
UPDATE dbo.ResLog_FailedMessage
SET RetryCount = @RetryCount, ResLogErrorTypeID = @ResLogErrorTypeID
WHERE ResLogID = @ResLogID AND MessageType = @MessageType
		

GO

GRANT EXECUTE ON [Admin_UpdateResLogFailedMessage] TO ExecuteOnlyRole

GO
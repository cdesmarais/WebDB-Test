-- If the procedure exists, drop it first
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetResLogFailedMessages]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetResLogFailedMessages]
GO

-- Create the procedure
CREATE PROCEDURE dbo.[Admin_GetResLogFailedMessages]
AS

-- Turns off messages SQL Server sends back to the client
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- return all inbox messages
SELECT	m.ResLogID, 
	m.MessageType,
	m.RetryCount,
	m.ContactInfo,
	ISNULL(m.ResLogErrorTypeID, 2) AS ResLogErrorTypeID, -- if errortypeid is null, return it as non-retry error.
	ISNULL(m.MessageText, '') AS MessageText,
	ISNULL(m.ResponseText, '') AS ResponseText,
	m.CreateDT
	FROM dbo.ResLog_FailedMessage m WITH (NOLOCK)		
	ORDER BY CreateDT DESC


GO

GRANT EXECUTE ON [Admin_GetResLogFailedMessages] TO ExecuteOnlyRole

GO
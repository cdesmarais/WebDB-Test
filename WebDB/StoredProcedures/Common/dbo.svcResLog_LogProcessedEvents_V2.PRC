-- Drop procedure needs to be before create type (ResLog_ProcessedMessages) because it references that type.
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[svcResLog_LogProcessedEvents_V2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[svcResLog_LogProcessedEvents_V2]
GO

-- Create type with ContactInfo if it does not exist
IF NOT EXISTS (SELECT * FROM sys.types WHERE name='ResLog_ProcessedMessages_V2' AND is_table_type=1)
	CREATE TYPE dbo.ResLog_ProcessedMessages_V2 AS TABLE 
	( 
		ResLogID		INT		NOT NULL,
		ContactInfo		NVARCHAR(256)	NOT NULL,
		MessageType		INT		NOT NULL,
		MessageText		NVARCHAR(MAX),
		ResponseText		NVARCHAR(MAX),
		ResLogErrorTypeID	INT,
		IsSucessful		BIT		NOT NULL
	);
GO

GRANT EXECUTE ON TYPE::dbo.ResLog_ProcessedMessages_V2 TO ExecuteOnlyRole
GO

CREATE PROCEDURE	[dbo].[svcResLog_LogProcessedEvents_V2]

@ProcessedMessages	ResLog_ProcessedMessages_V2 READONLY

AS

--Insert the ResLogID for the successfully sent message to the ResLog_SentMessage table
INSERT		dbo.ResLog_SentMessage
SELECT		p.ResLogID,
		p.MessageType,
		GETDATE(),
		p.ContactInfo,
		p.MessageText,
		p.ResponseText
FROM		@ProcessedMessages p
WHERE		p.IsSucessful = 1

--Update Count for existing failed messages
UPDATE		f
SET		RetryCount += 1
FROM		dbo.ResLog_FailedMessage f
INNER JOIN	@ProcessedMessages p
ON		f.ResLogID = p.ResLogID
AND             f.ContactInfo = p.ContactInfo
AND		0 = p.IsSucessful


--Add newly failed messages to ResLog_FailedMessage
INSERT		ResLog_FailedMessage
SELECT		p.ResLogID,
		p.MessageType,
		1 AS RetryCount,
		GETDATE() AS CreateDT,
		p.ContactInfo,
		p.ResLogErrorTypeID,
		p.MessageText,
		p.ResponseText
FROM		@ProcessedMessages p
LEFT JOIN	dbo.ResLog_FailedMessage f
ON		p.ResLogID = f.ResLogID
AND             p.ContactInfo = f.ContactInfo
AND		p.IsSucessful = 0
WHERE		f.ResLogID IS NULL


--Remove successfully sent messages from the ResLog_FailedMessage table
--** This must happen after the Insert action above**
DELETE		f
FROM		dbo.ResLog_FailedMessage f
INNER JOIN	@ProcessedMessages p
ON		f.ResLogID = p.ResLogID
AND		1 = p.IsSucessful


GO

GRANT EXECUTE ON [svcResLog_LogProcessedEvents_V2] TO ExecuteOnlyRole

GO

-- Drop procedure needs to be before create type (ResLog_ProcessedMessages) because it references that type.
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[svcResLog_LogIgnoredEvents]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[svcResLog_LogIgnoredEvents]
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


CREATE PROCEDURE	[dbo].[svcResLog_LogIgnoredEvents]

@IgnoredMessages	ResLog_ProcessedMessages_V2 READONLY

AS

--Insert the ResLogID for the successfully sent message to the ResLog_SentMessage table
INSERT		dbo.ResLog_IgnoredMessage
SELECT		im.ResLogID,
		im.MessageType,
		im.ContactInfo,
		im.MessageText,
		GETDATE()
FROM		@IgnoredMessages im

GO

GRANT EXECUTE ON [svcResLog_LogIgnoredEvents] TO ExecuteOnlyRole

GO

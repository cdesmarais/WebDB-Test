if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRecordOutboundEmail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRecordOutboundEmail]
GO

CREATE PROCEDURE dbo.DNRecordOutboundEmail

@EmailSender nvarchar(100),
@Recepients nvarchar(500),
@EmailDateTS datetime,
@EmailBody ntext,
@EmailSubject nvarchar(255),
@HostName nvarchar(100),
@EmailSource nvarchar(100)
AS

--*** OBSOLETE: After 2008R8 

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- insert data into the OutboundEmail table..
INSERT OutboundEmailVW(EmailSender,EmailRecepients,EmailDateTS,EmailBody,EmailSubject,EmailSource,HostName)
	VALUES(@EmailSender,@Recepients,@EmailDateTS,@EmailBody,@EmailSubject,@EmailSource,@HostName)

GO
GRANT EXECUTE ON [DNRecordOutboundEmail] TO ExecuteOnlyRole

GO

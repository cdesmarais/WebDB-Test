if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNLogLowSeverity]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNLogLowSeverity]
GO

CREATE PROCEDURE dbo.DNLogLowSeverity 
	@ServerID nvarchar(64),
	@MsgSource nvarchar(255),
	@Msg text,
	@SystemMsg text
AS

set nocount on

	INSERT INTO LogLowSeverity
	(ServerID,MsgSource,Msg,SystemMsg)
	VALUES
	(@ServerID,@MsgSource,@Msg,@SystemMsg)
GO



GRANT EXECUTE ON [DNLogLowSeverity] TO ExecuteOnlyRole

GO

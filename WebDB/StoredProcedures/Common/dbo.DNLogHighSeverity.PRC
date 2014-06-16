if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNLogHighSeverity]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNLogHighSeverity]
GO

CREATE PROCEDURE dbo.DNLogHighSeverity 
	@ServerID nvarchar(64),
	@MsgSource nvarchar(255),
	@Msg text,
	@SystemMsg text
AS
	set nocount on
	INSERT INTO LogHighSeverity
	(ServerID,MsgSource,Msg,SystemMsg)
	VALUES
	(@ServerID,@MsgSource,@Msg,@SystemMsg)
GO


GRANT EXECUTE ON [DNLogHighSeverity] TO ExecuteOnlyRole

GO

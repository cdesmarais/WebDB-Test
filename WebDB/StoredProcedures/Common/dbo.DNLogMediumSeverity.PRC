if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNLogMediumSeverity]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNLogMediumSeverity]
GO


CREATE PROCEDURE dbo.DNLogMediumSeverity 
	@ServerID nvarchar(64),
	@MsgSource nvarchar(255),
	@Msg text,
	@SystemMsg text
AS

set nocount on

	INSERT INTO LogMediumSeverity
	(ServerID,MsgSource,Msg,SystemMsg)
	VALUES
	(@ServerID,@MsgSource,@Msg,@SystemMsg)
GO



GRANT EXECUTE ON [DNLogMediumSeverity] TO ExecuteOnlyRole

GO

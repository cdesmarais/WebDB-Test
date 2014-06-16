if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNNagiosWriteStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNNagiosWriteStatus]
GO

CREATE Procedure dbo.DNNagiosWriteStatus
 (
	@NagiosTaskID	int,
	@Host			nvarchar(100),
	@Status			int,
	@UpdateDT		DateTime,
	@Msg			nvarchar(500)
 )
As

	set @Host = IsNull(@Host, '(NULL)')

	UPDATE NagiosTaskStatus SET Status = @Status, UpdateDT = @UpdateDT, Msg = @Msg
	WHERE	NagiosTaskID = @NagiosTaskID
		AND	Host = @Host
	IF @@ROWCOUNT = 0
	BEGIN
		--Record hasn't been created; insert it
		insert into NagiosTaskStatus (NagiosTaskID, Host, Status, UpdateDT, Msg)
			values (@NagiosTaskID, @Host, @Status, @UpdateDT, @Msg)

	END
	
	IF @@ERROR <> 0
	BEGIN
		declare @ErrorMsg as nvarchar(4000)
		set @ErrorMsg = 'DNNagiosWriteStatus Failed Error:' + Cast(IsNull(@@ERROR, 0) as nvarchar(10))
		exec DNErrorAdd 11001, 'DNNagiosWriteStatus', @ErrorMsg, 1
	END

GO

GRANT EXECUTE ON [DNNagiosWriteStatus] TO ExecuteOnlyRole
GRANT EXECUTE ON [DNNagiosWriteStatus] TO MonitorUser

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procLogProcedureError]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procLogProcedureError]
GO

CREATE Procedure dbo.procLogProcedureError
	@ErrorID int,
	@ProcName nvarchar(2000),
	@Action nvarchar(3000),
	@DBError nvarchar(100)
As


INSERT INTO ErrorLogVW	(
		ErrorID
		,ErrTimeStamp
		,ErrStackTrace
		,ErrMsg
		,ErrSeverity
		,HostName
	)
	values (
		@ErrorID
		,getdate()
		,'DB:' + @ProcName
		,'Action: ' + @Action + ' [DBError]:'+@DBError 
		,1
		,@@servername
	)

return scope_identity()

GO

  GRANT EXECUTE ON [procLogProcedureError] TO ExecuteOnlyRole
  GRANT EXECUTE ON [procLogProcedureError] TO MonitorUser

go

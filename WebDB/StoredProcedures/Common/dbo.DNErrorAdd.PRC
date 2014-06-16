if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNErrorAdd]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNErrorAdd]
GO

CREATE Procedure dbo.DNErrorAdd
@ErrorID int,
@ErrStackTrace nvarchar(2000),
@ErrMsg nvarchar(4000),
@ErrSeverity int
As

if (IsNull(@ErrSeverity,99) not in (1,2,3)) set @ErrSeverity = 3

INSERT INTO ErrorLogVW	(ErrorID,ErrTimeStamp,ErrStackTrace,ErrMsg,ErrSeverity, HostName)
	values(@ErrorID, getdate(), @ErrStackTrace, @ErrMsg, @ErrSeverity, @@servername)

return scope_identity()

GO
  GRANT EXECUTE ON [DNErrorAdd] TO ExecuteOnlyRole
  GRANT EXECUTE ON [DNErrorAdd] TO MonitorUser

go

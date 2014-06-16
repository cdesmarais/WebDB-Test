if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNLogError]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNLogError]
GO

CREATE Procedure dbo.DNLogError
@ErrorID int,
@ErrStackTrace nvarchar(2000),
@ErrMsg nvarchar(4000),
@ErrSeverity int,
@HostName nvarchar(100)

As


INSERT INTO ErrorLogVW	(ErrorID,ErrTimeStamp,ErrStackTrace,ErrMsg,ErrSeverity, HostName)
	values(@ErrorID, getdate(), @ErrStackTrace, @ErrMsg, @ErrSeverity, @HostName)

select scope_identity() ID

GO
  GRANT EXECUTE ON [DNLogError] TO ExecuteOnlyRole
  GRANT EXECUTE ON [DNLogError] TO MonitorUser

go

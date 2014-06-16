if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCallerChangeStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCallerChangeStatus]
GO

CREATE PROCEDURE dbo.DNCallerChangeStatus
(
	@CallerID int,
	@StatusID int
)
 AS
 SET NOCOUNT ON


update Caller set CallerStatusID = @StatusID where CallerID = @CallerID
GO


GRANT EXECUTE ON [DNCallerChangeStatus] TO ExecuteOnlyRole

GO

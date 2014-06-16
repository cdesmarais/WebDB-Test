if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_AuditRestStatusChg]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_AuditRestStatusChg]
GO




CREATE PROCEDURE dbo.Admin_AuditRestStatusChg
(
	@RID int,
	@UserID nvarchar(100),
	@NewStatus int
)
  
As

-- insert a new status change ONLY if the restaurant is NOT already in the state you are changing it to..
declare @LastRestState int
set @LastRestState = -1

select top 1 @LastRestState=newstatus from RestStatusTrackLog where rid=@RID order by statuschangedatets desc

-- update ONLY if the newstatus is NOT the same as the last known status of this restaurant - we only want to track state changes..
if @LastRestState <> @NewStatus
	BEGIN
		insert into RestStatusTrackLog(RID,UserID,NewStatus)
		VALUES(@RID,@UserID,@NewStatus)
	END


GO

GRANT EXECUTE ON [Admin_AuditRestStatusChg] TO ExecuteOnlyRole

GO

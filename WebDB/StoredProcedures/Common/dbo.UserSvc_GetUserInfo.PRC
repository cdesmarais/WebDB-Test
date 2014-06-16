if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UserSvc_GetUserInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UserSvc_GetUserInfo]
GO

CREATE Procedure dbo.UserSvc_GetUserInfo
 (
  @GlobalPersonId bigint
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

--*************************************************************
--** IMPORTANT: Please review any changes to this proc against:
--**	proc_UserSvc_GetCallerInfo
--**	proc_UserSvc_GetCustomerInfo
--**
--** These procs are part of a pair. 
--** They are split to make it easier to diff (for logical symmetry)
--** and for performance reasons
--*************************************************************

declare @CustID int, @CallerID int
 
select @CustID = CustID
	,@CallerID = CallerID
from GlobalPerson
where _GlobalPersonID = @GlobalPersonId

if @CallerID is not null
BEGIN
	exec proc_UserSvc_GetCallerInfo @CallerID
END
else
BEGIN
	exec proc_UserSvc_GetCustomerInfo @CustID
END

GO

GRANT EXECUTE ON [UserSvc_GetUserInfo] TO ExecuteOnlyRole
GO

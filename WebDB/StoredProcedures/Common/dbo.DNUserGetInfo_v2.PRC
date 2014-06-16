if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUserGetInfo_v2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUserGetInfo_v2]
GO

CREATE Procedure dbo.DNUserGetInfo_v2
 (
  @UserID int,
  @IsCaller int = 0
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

--*************************************************************
--** IMPORTANT: Please review any changes to this proc against:
--**	procDNUserGetInfo_Caller_v2
--**	procDNUserGetInfo_Cust_v2
--**
--** These procs are part of a pair. 
--** They are split to make it easier to diff (for logical symmetry)
--** and for performance reasons
--*************************************************************

if @IsCaller = 1
BEGIN
	exec procDNUserGetInfo_Caller_v2 @UserID
END
else
BEGIN
	exec procDNUserGetInfo_Cust_v2 @UserID
END

GO



GRANT EXECUTE ON [DNUserGetInfo_v2] TO ExecuteOnlyRole
GO

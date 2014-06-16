if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UserSvc_UpdateUserMetroID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UserSvc_UpdateUserMetroID]
GO

CREATE Procedure dbo.UserSvc_UpdateUserMetroID
 (
  @GlobalPersonId bigint,
  @MetroId int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @CustID int, @CallerID int
 
select @CustID = CustID
	,@CallerID = CallerID
from GlobalPerson
where _GlobalPersonID = @GlobalPersonId

if @CallerID is not null
BEGIN
	update caller set MetroAreaID = @MetroId where CallerId = @CallerId
END
else
BEGIN
	update customer set MetroAreaID = @MetroId where CustID = @CustID
END

GO

GRANT EXECUTE ON [UserSvc_UpdateUserMetroID] TO ExecuteOnlyRole
GO

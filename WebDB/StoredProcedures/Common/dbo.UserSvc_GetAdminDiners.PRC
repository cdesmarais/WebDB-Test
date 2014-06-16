if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UserSvc_GetAdminDiners]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UserSvc_GetAdminDiners]
GO

CREATE Procedure dbo.UserSvc_GetAdminDiners
 (
  @GlobalID bigint
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @isCaller bit
set @isCaller = (select case when CallerID is null then 0 else 1 end from GlobalPerson where _GlobalPersonID = @GlobalID)

if (@isCaller = 1)
begin
	select
		c.FName as FirstName,
		c.LName as LastName,
		c.CustID as CustomerID,
		c.SFname as SortableFirstName,
		c.SLname as SortableLastName,
		c.isAdmin as isAdmin
		   
		
	From	 CallerCustomer c
	inner join GlobalPerson gp  on c.CallerID = gp.CallerID
	where	gp._GlobalPersonID =  @GlobalID
	and c.Active = 1
end
else
	select
		null as FirstName,
		null as LastName,
		null as CustomerID,
		null as SortableFirstName,
		null as SortableLastName,
		null as isAdmin
GO


GRANT EXECUTE ON [UserSvc_GetAdminDiners] TO ExecuteOnlyRole
GO
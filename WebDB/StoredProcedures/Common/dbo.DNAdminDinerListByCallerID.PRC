if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNAdminDinerListByCallerID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNAdminDinerListByCallerID]
GO




CREATE PROCEDURE dbo.DNAdminDinerListByCallerID 

@CallerID int

AS
/*created 10/3/2003*/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @PositionID int
declare @CompanyID int

select @PositionID = PositionID, @CompanyID = CompanyID
from caller
where callerId = @CallerID 

if (@PositionID = 2) -- concierge
BEGIN
	--************************
	--** Concierge return all guest names for the hotel
	--** Allows concierge to share guests
	--************************
	Select cc.FName as FirstName,
		cc.LName as LastName,
		cc.SFName as SortableFirstName,
		cc.SLName as SortableLastName,
		cc.CustID as Customer_ID,
		coalesce(ContactPhone,'') As Phone,
		cc.IsAdmin as IsAdmin		
	From callercustomer cc
	where cc.CompanyID = @CompanyID 
	and cc.Active = 1
	order by cc.SLname, cc.Lname
END
ELSE
BEGIN
	Select FName as FirstName,LName as LastName,
		SFName as SortableFirstName,
		SLName as SortableLastName,
		CustID as Customer_ID,
		coalesce(ContactPhone,'') As Phone,
		IsAdmin as IsAdmin
	From CallerCustomer
	where CallerID = @CallerID and Active = 1
	order by SLname, Lname
END

GO


GRANT EXECUTE ON [DNAdminDinerListByCallerID] TO ExecuteOnlyRole

GO

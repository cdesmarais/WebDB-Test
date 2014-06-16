if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetCountAllResosByCustomerID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetCountAllResosByCustomerID]
GO

CREATE PROCEDURE dbo.Admin_GetCountAllResosByCustomerID 

@CustomerID int,
@IsCaller bit

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

if @IsCaller = 0 
	select count(ResID) as resos from Reservation where CustID = @CustomerID
	
if @IsCaller = 1
BEGIN
    Select count(ResID) as resos from Reservation where CustID in (Select CustID from CallerCustomer where CallerID = @CustomerID)
END

GO

GRANT EXECUTE ON [Admin_GetCountAllResosByCustomerID] TO ExecuteOnlyRole

GO

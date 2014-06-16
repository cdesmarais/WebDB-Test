if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUserGetDetailInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUserGetDetailInfo]
GO


CREATE Procedure dbo.DNUserGetDetailInfo
 (
  @UserID int,
  @IsCaller int = 0
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

if(@IsCaller = 0)
Begin
SELECT 
    Customer.Address1 as Address,Customer.City,
    Customer.Address2,
    Customer.State,Customer.Zip AS ZipCode,
    Customer.Country
FROM Customer 
WHERE (Customer.CustID = @UserID)
End
ELSE
Begin
SELECT 

    Caller.Address1 as Address,Caller.City,
    Caller.Address2,
    Caller.State,Caller.Zip AS ZipCode,
    Caller.Country
FROM Caller
WHERE (Caller.CallerID = @UserID)
End
GO

GRANT EXECUTE ON [DNUserGetDetailInfo] TO ExecuteOnlyRole

GO

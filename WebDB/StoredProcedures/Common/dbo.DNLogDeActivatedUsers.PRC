if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNLogDeActivatedUsers]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNLogDeActivatedUsers]
GO


CREATE PROCEDURE dbo.DNLogDeActivatedUsers
(
@CustomerID int,
@isAdmin int,
@ReasonID int
)
 AS
 SET NOCOUNT ON

if (@isAdmin = 0)
BEGIN
	Insert into CustomersDeactivated (CustID,ReasonID)
	VALUES (@CustomerID,@ReasonID)
END
else
BEGIN
	Insert into CustomersDeactivated (CallerID,ReasonID)
	VALUES (@CustomerID,@ReasonID)
END
GO

GRANT EXECUTE ON [DNLogDeActivatedUsers] TO ExecuteOnlyRole

GO

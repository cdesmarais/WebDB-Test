if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_ReActivate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_ReActivate]
GO



CREATE Procedure dbo.User_ReActivate
(@CustID int
)
 AS
 SET NOCOUNT ON

update Customer set active =1 where CustID = @CustID

delete from Customers_Inactivated where CustID = @CustID



GO

GRANT EXECUTE ON [User_ReActivate] TO ExecuteOnlyRole

GO

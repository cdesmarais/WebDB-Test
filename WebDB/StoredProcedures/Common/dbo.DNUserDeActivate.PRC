if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUserDeActivate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUserDeActivate]
GO

CREATE PROCEDURE dbo.DNUserDeActivate
(@CustomerID int
)
 AS
 SET NOCOUNT ON

update Customer set active = 0 where CustID = @CustomerID


GO


GRANT EXECUTE ON [DNUserDeActivate] TO ExecuteOnlyRole

GO

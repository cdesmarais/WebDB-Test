if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_NewUsers]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_NewUsers]
GO



CREATE PROCEDURE dbo.Daily_NewUsers
(
@strDateOffset int
)

AS
set transaction isolation level read uncommitted
SET NOCOUNT ON

SELECT COUNT(CustID) AS NewUserCount 
FROM Customer 
where datediff(d,Customer.createdate,getdate()- @strDateOffset) = 0


GO

GRANT EXECUTE ON [Daily_NewUsers] TO ExecuteOnlyRole

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_TotalAnonUsers]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_TotalAnonUsers]
GO







CREATE    PROCEDURE dbo.Daily_TotalAnonUsers
@strDateOffset		int
AS

--Total # of Anonymous users

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

SELECT COUNT(CustID) AS Total_Anonymous_Customers
FROM Customer
WHERE ConsumerType = 8
	AND DATEDIFF(d,createdate,getdate()) >= @strDateOffset
RETURN







GO

GRANT EXECUTE ON [Daily_TotalAnonUsers] TO ExecuteOnlyRole

GO

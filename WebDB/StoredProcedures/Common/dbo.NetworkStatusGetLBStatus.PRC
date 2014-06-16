if exists (select * from dbo.sysobjects where id = object_id(N'dbo.NetworkStatusGetLBStatus') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[NetworkStatusGetLBStatus]
GO

CREATE PROCEDURE [dbo].[NetworkStatusGetLBStatus]
(
	@ServerIP nvarchar(20)
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT		lb.Code
FROM		[Server] s 
INNER JOIN	LBStatusCode lb 
ON			lb.ID = s.LBStatusCode
WHERE		s.IPAddress = @ServerIP
GO

GRANT EXECUTE ON [dbo].[NetworkStatusGetLBStatus] TO ExecuteOnlyRole
GO


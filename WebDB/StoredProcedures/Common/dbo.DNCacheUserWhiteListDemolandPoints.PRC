if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheUserWhiteListDemolandPoints]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheUserWhiteListDemolandPoints]
go

CREATE PROCEDURE [dbo].[DNCacheUserWhiteListDemolandPoints] 
AS
	SELECT	ISNULL([CustomerID], -1) AS [CustomerID], ISNULL([CallerID], -1) AS [CallerID]
	FROM	[dbo].[UserPointsList] WITH (NOLOCK)
GO

GRANT EXECUTE ON [DNCacheUserWhiteListDemolandPoints] TO ExecuteOnlyRole
GO
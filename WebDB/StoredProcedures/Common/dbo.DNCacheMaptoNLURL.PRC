if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheMapToNLURL]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheMapToNLURL]
go

CREATE PROCEDURE [dbo].[DNCacheMapToNLURL]
AS
	select [NLDataID], [NLRuleID],
			ISNULL([QSData1], -1) AS [QSData1],
			ISNULL([QSData2], -1) AS [QSData2],
			ISNULL([QSData3], -1) AS [QSData3],
			[NLURL]
	from	[dbo].[NLURLVW]
	where [Active] = 1 ----  [Active] = 1
go

GRANT EXECUTE ON [DNCacheMapToNLURL] TO ExecuteOnlyRole
GO
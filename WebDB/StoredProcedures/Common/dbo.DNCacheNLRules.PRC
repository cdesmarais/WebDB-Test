if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheNLRules]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheNLRules]
go

CREATE PROCEDURE [dbo].[DNCacheNLRules]
AS
select	[NLRuleID], [PageName], [Rank], [QSPrefix1], [QSPrefix2], [QSPrefix3]
from		[dbo].[NLRule]
order by [PageName],[Rank]
go

GRANT EXECUTE ON [DNCacheNLRules] TO ExecuteOnlyRole
GO
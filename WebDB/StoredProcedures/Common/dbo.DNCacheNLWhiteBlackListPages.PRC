if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheNLWhiteBlackListPages]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheNLWhiteBlackListPages]
go

CREATE PROCEDURE [dbo].[DNCacheNLWhiteBlackListPages]
AS
select	[OTPageEnum],[translate]
from	[dbo].[NLPageLists]
go

GRANT EXECUTE ON [DNCacheNLWhiteBlackListPages] TO ExecuteOnlyRole
GO

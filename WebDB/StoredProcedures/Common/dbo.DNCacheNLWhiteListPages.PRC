if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheNLWhiteListPages]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheNLWhiteListPages]
go

CREATE PROCEDURE [dbo].[DNCacheNLWhiteListPages]
AS
select	[OTPageEnum]
from	[dbo].[NLPageLists]
where  	[translate]=1  -- white list pages
go

GRANT EXECUTE ON [DNCacheNLWhiteListPages] TO ExecuteOnlyRole
GO
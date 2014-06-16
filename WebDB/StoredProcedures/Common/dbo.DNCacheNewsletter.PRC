if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheNewsletter]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheNewsletter]
GO

CREATE Procedure dbo.DNCacheNewsletter

As

SET NOCOUNT ON

select Newsletterid, Name
from Newsletter

GO


GRANT EXECUTE ON [DNCacheNewsletter] TO ExecuteOnlyRole
GO


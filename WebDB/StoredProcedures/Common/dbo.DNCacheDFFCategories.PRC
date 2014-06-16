if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheDFFCategories]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheDFFCategories]
GO

CREATE PROCEDURE dbo.DNCacheDFFCategories
 As

SET NOCOUNT ON

set transaction isolation level read uncommitted -- Don't read from DFFCategoriesHolding table while otservice is updating it from MySQL

Select		CategoryID
			,Description as CategoryName		
from		DFFCategoriesHolding
order by 	CategoryID
GO

GRANT EXECUTE ON [DNCacheDFFCategories] TO ExecuteOnlyRole

GO

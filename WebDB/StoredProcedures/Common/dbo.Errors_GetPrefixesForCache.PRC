if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Errors_GetPrefixesForCache]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Errors_GetPrefixesForCache]
GO





CREATE Procedure dbo.Errors_GetPrefixesForCache

 AS
SET NOCOUNT ON
select '1' as Language_ID,'e_' as asp_caching_prefix
GO

GRANT EXECUTE ON [Errors_GetPrefixesForCache] TO ExecuteOnlyRole

GO

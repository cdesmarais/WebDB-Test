if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CitySearch_GetURLsForCache]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CitySearch_GetURLsForCache]
GO




CREATE PROCEDURE dbo.CitySearch_GetURLsForCache
AS
SET NOCOUNT ON

Select citysearch_ID,outside_url
From citysearch_URLs
where active = 1



GO

GRANT EXECUTE ON [CitySearch_GetURLsForCache] TO ExecuteOnlyRole

GO

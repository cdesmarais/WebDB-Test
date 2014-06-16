if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheSiteMapXML]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheSiteMapXML]
GO


CREATE PROCEDURE dbo.DNCacheSiteMapXML
As

SET NOCOUNT ON

SELECT 		[SiteMapID], 
		[DomainID], 
		[XMLFileName],		
		[XMLFile],
		[FileDate]
FROM 		[SiteMapXML]

GO

GRANT EXECUTE ON [DNCacheSiteMapXML] TO ExecuteOnlyRole

GO


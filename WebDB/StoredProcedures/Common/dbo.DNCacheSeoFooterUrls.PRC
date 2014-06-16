
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheSeoFooterUrls]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheSeoFooterUrls]
GO


CREATE PROCEDURE dbo.DNCacheSeoFooterUrls
 As

SET NOCOUNT ON
set transaction isolation level read uncommitted

-- TODO - Check with Angela, if sort order matters create new colunn and return in SP.

Select			url, sortorder, anchor, s.urltypeid, domainid, t.description
FROM			seofooterlinks s
INNER JOIN      seofooterurltype t ON t.urltypeid = s.urltypeid
ORDER BY		urltypeid, anchor
GO

GRANT EXECUTE ON [DNCacheSeoFooterUrls] TO ExecuteOnlyRole

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheServerList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheServerList]
GO

CREATE PROCEDURE dbo.DNCacheServerList
As

SET NOCOUNT ON

select     cs.CacheServerID, 
           cs.InternalDNS, 
           cs.PortNumber, 
           s.IPAddress
from       CacheServer     cs
inner join Server          s
on         s.ServerID      = cs.ServerID
where      s.Active        = 1
 
GO

GRANT EXECUTE ON [DNCacheServerList] TO ExecuteOnlyRole

GO

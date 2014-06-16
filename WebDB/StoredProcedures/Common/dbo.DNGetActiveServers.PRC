if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetActiveServers]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetActiveServers]
GO

CREATE PROCEDURE dbo.DNGetActiveServers
AS

SET NOCOUNT ON

--**********************
--**Only retrieve server IPs if:
--**	Server is Active
--**    Server has a Consumer Website on it (not a service)
--**********************

select		distinct s.IPAddress as serverip,
			s.serverid,
			isnull(s.ImageUploadTransactionID,0) as imguploadtxid
from		Server s
inner join	ServerSite ss
ON			s.ServerID = ss.ServerID 
inner join	SiteType st
ON			st.SiteTypeID = ss.SiteTypeID
where		s.active = 1 
and			st.Service = 0
and			isnull(s.ImageUploadTransactionID,0) != 0
and			s.acceptsTraffic = 1
and			st.Instance like 'Web[_]%'-- Only return the consumer websites


GO

GRANT EXECUTE ON [DNGetActiveServers] TO ExecuteOnlyRole

GO
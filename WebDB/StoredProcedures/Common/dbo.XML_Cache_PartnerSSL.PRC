if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XML_Cache_PartnerSSL]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XML_Cache_PartnerSSL]
GO

CREATE PROCEDURE dbo.XML_Cache_PartnerSSL

AS
SET NOCOUNT ON

Select 
		IPAddress as IP_Address
		,sslsecurity as ssl_security
From Partner
inner join PartnerIPs 
on Partner.PartnerID = PartnerIPs.PartnerID
Where XMLFlag = 1

GO

GRANT EXECUTE ON [XML_Cache_PartnerSSL] TO ExecuteOnlyRole

GO

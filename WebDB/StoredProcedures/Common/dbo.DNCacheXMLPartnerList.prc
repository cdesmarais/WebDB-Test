if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheXMLPartnerList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheXMLPartnerList]
GO

-- Modified to include server IPs and special PartnerIDs that 

CREATE PROCEDURE dbo.DNCacheXMLPartnerList
As
SET NOCOUNT ON
set transaction isolation level read uncommitted  

-- get the non-RESTAPI partners and their IP addresses
SELECT			pips.ipaddress, 
				p.partnerid, 
				p.EmailOn, 
				p.PointsOn,
				p.PartnerName,
				p.IsRESTAPIClient,
				p.Passphrase,
				p.EncryptionSalt,
				p.OutputFormat,
				p.RequireIPhone,
				p.RequireSSL,
				p.ValidationMethod,
				p.PublicKey,
				p.UseNativeMethodCalls,
				p.OAuthKey,
				p.OAuthSecret,
				p.InputFormat,
				p.WebServiceTierID,
				p.PartnerTypeID,
				p.CoBrandEmail,
				cast(isnull(p.CreditCardEnabled,0) as bit) CreditCardEnabled,
				cast(isnull(p.ProductionEnabled,0) as bit) ProductionEnabled,
				cast(isnull(p.IsMobileSite,0) as bit) IsMobileSite,
				cast(isnull(p.RestaurantEmailOptInEnabled,0) as bit) RestaurantEmailOptInEnabled,
				p.NoPointsMessage
FROM			PartnerVW p
LEFT JOIN		PartnerIPs pips
ON				p.partnerid = pips.partnerid
WHERE			p.IsRESTAPIClient = 0
AND				p.ActiveFlag = 1
UNION ALL
-- also get the RESTAPI partners and the active Server IPs
SELECT			s.IPAddress,
				p.PartnerID,
				p.EmailOn,
				p.PointsOn,
				p.PartnerName,
				p.IsRESTAPIClient,
				p.Passphrase,
				p.EncryptionSalt,
				p.OutputFormat,
				p.RequireIPhone,
				p.RequireSSL,
				p.ValidationMethod,
				p.PublicKey,
				p.UseNativeMethodCalls,
				p.OAuthKey,
				p.OAuthSecret,
				p.InputFormat,
				p.WebServiceTierID,
				p.PartnerTypeID,
				p.CoBrandEmail,
				cast(isnull(p.CreditCardEnabled,0) as bit) CreditCardEnabled,
				cast(isnull(p.ProductionEnabled,0) as bit) ProductionEnabled,
				cast(isnull(p.IsMobileSite,0) as bit) IsMobileSite,
				cast(isnull(p.RestaurantEmailOptInEnabled,0) as bit) RestaurantEmailOptInEnabled,
				p.NoPointsMessage as bit
FROM			partnerVW p
CROSS JOIN		[Server] s 
WHERE			s.Active = 1 		
AND 			(p.IsRESTAPIClient = 1 
OR				p.partnertypeid = 4)
UNION ALL
-- also associate the RESTAPI partners with the loopback address
SELECT			'127.0.0.1',
				p.PartnerID,
				p.EmailOn,
				p.PointsOn,
				P.PartnerName,
				p.IsRESTAPIClient,
				p.Passphrase,
				p.EncryptionSalt,
				p.OutputFormat,
				p.RequireIPhone,
				p.RequireSSL,
				p.ValidationMethod,
				p.PublicKey,
				p.UseNativeMethodCalls,
				p.OAuthKey,
				p.OAuthSecret,
				P.InputFormat,
				p.WebServiceTierID,
				p.PartnerTypeID,
				p.CoBrandEmail,
				cast(isnull(p.CreditCardEnabled,0) as bit) CreditCardEnabled,
				cast(isnull(p.ProductionEnabled,0) as bit) ProductionEnabled,
				cast(isnull(p.IsMobileSite,0) as bit) IsMobileSite,
				cast(isnull(p.RestaurantEmailOptInEnabled,0) as bit) RestaurantEmailOptInEnabled,
				p.NoPointsMessage as bit
FROM			partnerVW p
WHERE			p.ActiveFlag = 1
AND				(p.IsRESTAPIClient = 1 
OR	    		p.partnertypeid = 4)
ORDER BY p.partnerid, ipaddress

GO


GRANT EXECUTE ON [DNCacheXMLPartnerList] TO ExecuteOnlyRole

GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_PartnerGet]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_PartnerGet]
GO


create procedure dbo.Admin_PartnerGet(
			@partnerid int
)
As

set nocount on
set transaction isolation level read uncommitted
  
	select 
				p.PartnerName
				, p.SSLSecurity
				, p.EmailOn
				, p.PointsOn
				, p.IsRESTAPIClient
				, p.PartnerTypeID
				, p.OTContact
				, p.ContractFlag
				, p.PartnerApiVersion
				, p.LicenseTerms
				, p.WebServiceTierID
				, p.Notes
				, p.PartnerContactName
				, p.PartnerContactEmail
				, p.PartnerContactPhone
				, p.ActiveFlag
				, p.Passphrase as Password
				, p.OAuthKey
				, p.OAuthSecret
				, p.CoBrandEmail
				, p.ProductionEnabled
				, p.EmailDFF
				, p.ReportingSourceTypeId
				, p.ReportingDisplayName
				, p.NoPointsMessage
	from		PartnerVW p	
	where		p.partnerid = @partnerid 

go

grant execute on [Admin_PartnerGet] to ExecuteOnlyRole

go

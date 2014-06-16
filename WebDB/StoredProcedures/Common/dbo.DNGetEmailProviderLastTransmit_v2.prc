if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetEmailProviderLastTransmit_v2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetEmailProviderLastTransmit_v2]
GO


CREATE PROCEDURE dbo.DNGetEmailProviderLastTransmit_v2(
			@EmailProviderName nvarchar(40),
			@PartnerFeedTypeID int, 
			@LastTransmitUTC datetime output					
)
As

SET NOCOUNT ON
/*
	Find the last time we successfully transmitted to the email provider
*/

	select			@LastTransmitUTC = max(DateRangeEndUTC)
	from			EmailProviderFileTransmission epft
	inner join		EmailProvider ep
	on				epft.EmailProviderID = ep.EmailProviderID
	where			ep.EmailProviderName = @EmailProviderName
	AND             epft.PartnerFeedTypeID = @PartnerFeedTypeID
GO

GRANT EXECUTE ON [DNGetEmailProviderLastTransmit_v2] TO ExecuteOnlyRole

GO

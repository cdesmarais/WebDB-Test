if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetEmailProviderLastTransmit]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetEmailProviderLastTransmit]
GO


CREATE PROCEDURE dbo.DNGetEmailProviderLastTransmit(
			@EmailProviderName nvarchar(40),
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
	
GO

GRANT EXECUTE ON [DNGetEmailProviderLastTransmit] TO ExecuteOnlyRole

GO

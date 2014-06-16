if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRecordEmailProviderTransmit_v2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRecordEmailProviderTransmit_v2]
GO


CREATE PROCEDURE dbo.DNRecordEmailProviderTransmit_v2(
	@EmailProviderName		nvarchar(40),
	@DateRangeBeginUTC		datetime,
	@DateRangeEndUTC		datetime,
	@RecordCount			int,
	@FileTransmissionName	nvarchar(50),
	@PartnerFeedTypeID	    int 				
)
As

SET NOCOUNT ON
/*
	Record file transmission for an external email provider
*/

	insert into EmailProviderFileTransmission (EmailProviderID, DateRangeBeginUTC, DateRangeEndUTC, RecordCount, FileTransmissionName, PartnerFeedTypeID) 
	select			EmailProviderID,
					@DateRangeBeginUTC,
					@DateRangeEndUTC,
					@RecordCount,
					@FileTransmissionName,
					@PartnerFeedTypeID
	from			EmailProvider
	where			EmailProviderName = @EmailProviderName
	
	if @@error != 0 or @@rowcount != 1
		raiserror('Unable to insert EmailProviderFileTransmission record',16,1)
	
GO

GRANT EXECUTE ON [DNRecordEmailProviderTransmit_v2] TO ExecuteOnlyRole

GO
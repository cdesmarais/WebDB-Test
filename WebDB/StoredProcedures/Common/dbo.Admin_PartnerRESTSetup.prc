if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_PartnerRESTSetup]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_PartnerRESTSetup]
GO


CREATE PROCEDURE dbo.Admin_PartnerRESTSetup(
			@PartnerID int,
			@OAuthKey nvarchar(4000),
			@OAuthSecret nvarchar(4000)			
)
As

SET NOCOUNT ON
/*
	Enable client on the REST API	
*/

	--Don't attempt to insert any rows if we've already got a parameter for the
	--validation method named OAuth
	if exists (	select		1 
				from		PartnerPartnerParameter 
				where		PartnerID = @PartnerID
				and			PartnerParameterID = 6
				and			ParameterValue = 'OAuth'
				)
				return 1

	--Set this up as an all or nothing insert if any of the values fail, then roll everything back.
	insert into PartnerPartnerParameter (PartnerID, PartnerParameterID, ParameterValue) values (@PartnerID,3,'JSON')
			
	insert into PartnerPartnerParameter (PartnerID, PartnerParameterID, ParameterValue) values (@PartnerID,5,'true')
			
	insert into PartnerPartnerParameter (PartnerID, PartnerParameterID, ParameterValue) values (@PartnerID,6,'OAuth')
			
	insert into PartnerPartnerParameter (PartnerID, PartnerParameterID, ParameterValue) values (@PartnerID,8,'true')
	
	insert into PartnerPartnerParameter (PartnerID, PartnerParameterID, ParameterValue) values (@PartnerID,9,@OAuthKey)
			
	insert into PartnerPartnerParameter (PartnerID, PartnerParameterID, ParameterValue) values (@PartnerID,10,@OAuthSecret)

return 0

GO

GRANT EXECUTE ON [Admin_PartnerRESTSetup] TO ExecuteOnlyRole

GO

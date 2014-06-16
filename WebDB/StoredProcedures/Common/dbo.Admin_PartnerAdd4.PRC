/* Deprecated, this stored proc should be dropped after WR_11_10 deploys */
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_PartnerAdd4]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_PartnerAdd4]
go


create procedure dbo.Admin_PartnerAdd4 (
			@partnername nvarchar(50),
			@SSLSecurity bit,
			@EmailOn bit,
			@PointsOn bit,
			@IsRESTAPIClient bit,
			@PartnerTypeID int,
			@OTContact nvarchar(161),
			@ContractFlag bit,
			@PartnerApiVersion nvarchar(100),
			@LicenseTerms nvarchar(1000),
			@WebServiceTierID int,
			@Notes nvarchar(1000),
			@PartnerContactName nvarchar(161),
			@PartnerContactEmail nvarchar(150),
			@PartnerContactPhone varchar(24),
			@ActiveFlag bit,
			@Password nvarchar (4000),
			@CoBrandEmail bit,
			@ProductionEnabled bit,
			@PartnerID int out
)
as

set nocount on
begin transaction
  
	insert into partner (
			PartnerName,
			SSLSecurity,
			EmailOn,
			PointsOn,
			IsRESTAPIClient,
			PartnerTypeID,
			OTContact,
			ContractFlag,
			PartnerApiVersion,
			LicenseTerms,
			WebServiceTierID,
			Notes,
			PartnerContactName,
			PartnerContactEmail,
			PartnerContactPhone,
			ActiveFlag,
			CoBrandEmail)
	values (
			@partnername,
			@SSLSecurity,
			@EmailOn,
			@PointsOn,
			@IsRESTAPIClient,
			@PartnerTypeID,
			@OTContact,
			@ContractFlag,
			@PartnerApiVersion,
			@LicenseTerms,
			@WebServiceTierID,
			@Notes,
			@PartnerContactName,
			@PartnerContactEmail,
			@PartnerContactPhone,
			@ActiveFlag,
			@CoBrandEmail)
			
	if (@@error <> 0)
		goto general_error
	  
	select @PartnerID = scope_identity()

	if (@password != '' AND @password is not null)
	begin	
		insert into partnerpartnerParameter (PartnerID, PartnerParameterID,ParameterValue)
		values (@PartnerID, 1, @Password)
		if (@@error <> 0)
			goto general_error
	end
		
		insert into PartnerPartnerParameter
		(PartnerID, PartnerParameterID, ParameterValue)
		values (@PartnerID, 13, cast(isnull(@ProductionEnabled,0) as nvarchar))
		if (@@error <> 0)
			goto general_error
		
commit transaction
return(0)

general_error:
	rollback transaction
	raiserror('Encountered a failure when adding Partner data',16,1)

go

grant execute on [Admin_PartnerAdd4] TO ExecuteOnlyRole

go


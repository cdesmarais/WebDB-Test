/* Deprecated, this stored proc should be dropped after WR_11_10 deploys */
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_PartnerUpdate4]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_PartnerUpdate4]
GO


CREATE PROCEDURE dbo.Admin_PartnerUpdate4 (
						@PartnerID int,
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
						@ProductionEnabled bit
)
As

SET NOCOUNT ON
BEGIN TRANSACTION

	update partner
	set
						PartnerName = @partnername,
						SSLSecurity = @SSLSecurity,
						EmailOn = @EmailOn,
						PointsOn = @PointsOn,
						IsRESTAPIClient = @IsRESTAPIClient,
						PartnerTypeID = @PartnerTypeID,
						OTContact = @OTContact,
						ContractFlag = @ContractFlag,
						PartnerApiVersion = @PartnerApiVersion,
						LicenseTerms = @LicenseTerms,
						WebServiceTierID = @WebServiceTierID, 
						Notes = @Notes,
						PartnerContactName = @PartnerContactName,
						PartnerContactEmail = @PartnerContactEmail,
						PartnerContactPhone = @PartnerContactPhone,
						ActiveFlag = @ActiveFlag,
						CoBrandEmail = @CoBrandEmail
						
	where				partnerid = @PartnerID
	
	if (@@ERROR <> 0)
		goto general_error

	if exists(select PartnerID from partnerpartnerParameter where PartnerID = @PartnerID and PartnerParameterID = 1)
		BEGIN
		
			if(@Password != '' AND @Password is not null) -- if @password has value and a row already exists in partnerpartnerParameter
				BEGIN
				
					update	partnerpartnerParameter 
					set		ParameterValue = @Password
					where	PartnerID = @PartnerID
					and		PartnerParameterID = 1 -- password parameter type
				
				END
			
			ELSE -- @Password was intentionally set to empty (password deleted by user)
				BEGIN
		
					delete
					from		partnerpartnerParameter
					where		PartnerID = @PartnerID
					and			PartnerParameterID = 1 --password parameter type
		
				END					
				
		END
		
	ELSE -- no row exists in partnerpartnerParameter
		
			BEGIN
			
				if(@Password != '' AND @Password is not null) -- if @password has value and a no row exists in partnerpartnerParameter, insert a new row
				BEGIN	
					insert into partnerpartnerParameter (PartnerID, PartnerParameterID,ParameterValue)
					values (@PartnerID, 1, @Password)
				END
		
			END
		
	if (@@ERROR <> 0)
		goto general_error

	--Set the value for ProductionEnabled
	if exists(select PartnerID from partnerpartnerParameter where PartnerID = @PartnerID and PartnerParameterID = 13)
		BEGIN
					
			update		PartnerPartnerParameter
			set			ParameterValue = cast(isnull(@ProductionEnabled,'0') as nvarchar)
			where		PartnerID = @PartnerID
			and			PartnerParameterID = 13
			
		END	
	ELSE -- no row exists in partnerpartnerParameter
		BEGIN		
			insert into partnerpartnerParameter (PartnerID, PartnerParameterID,ParameterValue)
			values		(@PartnerID, 13, cast(isnull(@ProductionEnabled,'0') as nvarchar))		
		
		END
		
	if (@@ERROR <> 0)
		goto general_error


COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(1)
		
GO

GRANT EXECUTE ON [Admin_PartnerUpdate4] TO ExecuteOnlyRole

GO


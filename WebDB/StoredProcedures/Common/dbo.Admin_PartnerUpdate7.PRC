

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_PartnerUpdate7]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_PartnerUpdate7]
go


create procedure dbo.Admin_PartnerUpdate7 (
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
						@ProductionEnabled bit,
						@EmailDFF bit,
						@ReportingSourceTypeID int,
						@ReportingDisplayName nvarchar(256),
						@NoPointsMessage bit
)
as

set nocount on
begin transaction

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
						CoBrandEmail = @CoBrandEmail,
						ReportingSourceTypeID = @ReportingSourceTypeID,
						ReportingDisplayName = @ReportingDisplayName,
						NoPointsMessage = @NoPointsMessage
						
	where				partnerid = @PartnerID
	
	if (@@ERROR <> 0)
		goto general_error

	if exists(select PartnerID from partnerpartnerParameter where PartnerID = @PartnerID and PartnerParameterID = 1)
		begin
		
			if(@Password != '' AND @Password is not null) -- if @password has value and a row already exists in partnerpartnerParameter
				begin
				
					update	partnerpartnerParameter 
					set		ParameterValue = @Password
					where	PartnerID = @PartnerID
					and		PartnerParameterID = 1 -- password parameter type
				
				end
			
			else -- @Password was intentionally set to empty (password deleted by user)
				begin
		
					delete
					from		partnerpartnerParameter
					where		PartnerID = @PartnerID
					and			PartnerParameterID = 1 --password parameter type
		
				end					
				
		end
		
	else -- no row exists in partnerpartnerParameter
		
			begin
			
				if(@Password != '' AND @Password is not null) -- if @password has value and a no row exists in partnerpartnerParameter, insert a new row
				begin	
					insert into partnerpartnerParameter (PartnerID, PartnerParameterID,ParameterValue)
					values (@PartnerID, 1, @Password)
				end
		
			end
		
	if (@@ERROR <> 0)
		goto general_error

	--Set the value for ProductionEnabled
	if exists(select PartnerID from partnerpartnerParameter where PartnerID = @PartnerID and PartnerParameterID = 13)
		begin
					
			update		PartnerPartnerParameter
			set			ParameterValue = cast(isnull(@ProductionEnabled,'0') as nvarchar)
			where		PartnerID = @PartnerID
			and			PartnerParameterID = 13
			
		end	
	else -- no row exists in partnerpartnerParameter
		begin		
			insert into partnerpartnerParameter (PartnerID, PartnerParameterID,ParameterValue)
			values		(@PartnerID, 13, cast(isnull(@ProductionEnabled,'0') as nvarchar))		
		
		end

	if (@@ERROR <> 0)
		goto general_error
		
	--Set the value for the EmailDFF bit
	if exists(select PartnerID from partnerpartnerParameter where PartnerID = @PartnerID and PartnerParameterID = 14)
		begin
					
			update		PartnerPartnerParameter
			set			ParameterValue = cast(isnull(@EmailDFF,'1') as nvarchar)
			where		PartnerID = @PartnerID
			and			PartnerParameterID = 14
			
		end	
	else -- no row exists in partnerpartnerParameter
		begin		
			insert into partnerpartnerParameter (PartnerID, PartnerParameterID,ParameterValue)
			values		(@PartnerID, 14, cast(isnull(@EmailDFF,'1') as nvarchar))		
		
		end
			
	if (@@ERROR <> 0)
		goto general_error


commit transaction
Return(0)

general_error:
	rollback transaction
	Return(1)
		
go

grant execute on [Admin_PartnerUpdate7] to ExecuteOnlyRole

go


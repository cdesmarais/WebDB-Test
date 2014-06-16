if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UserSvc_SetCustomerInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UserSvc_SetCustomerInfo]
GO

CREATE Procedure dbo.UserSvc_SetCustomerInfo
 (
	@GlobalPersonId bigint,
	@Hash varchar(128),
	@Salt varchar(128),
	@UserTokenTypeID  tinyint,
	@Email nvarchar(1000), -- NULL,
	@LoginName nvarchar(1000), -- NULL,	
	@FName nvarchar(1000), -- NULL,
	@LName nvarchar(1000), --(40) NULL,
	@SFname nvarchar(1000), -- NULL,
	@SLname nvarchar(1000), -- NULL,
	@Address1 nvarchar(1000), -- NULL,
	@Address2 nvarchar(1000), -- NULL,
	@City nvarchar(1000), -- NULL,
	@State nvarchar(1000), -- NULL,
	@ZIP nvarchar(1000), -- NULL,
	@Country char(2), -- NULL,
	@MetroAreaID int,-- NULL,
	@SpecialRequest nvarchar(1000), --(999) NULL,
	
	@PhoneCountryID char(2),
	@DayPhone nvarchar(24),
	@MobilePhoneCountryID char(2),
	@MobilePhone nvarchar(24)
--	@Pwd nvarchar(1000), -- NULL,
--	@Active bit NOT NULL,
	--SendPromoMail bit NOT NULL,
	--PwdAttempt int NOT NULL,
	--SendPromoEmail bit NOT NULL,
	--CreateDate datetime NOT NULL,
	--Points int NOT NULL,
	--@SendAnnouncements bit NOT NULL,
	--@PartnerID int NULL,
	--PwdQuestionID int NULL,
	--PwdAnswer nvarchar(25) NULL,
	--CallerID int NULL,
	--ConsumerType int NOT NULL,
	--Salutation int NULL,
	--BirthMonth int NULL,
	--BirthYear int NULL,
	--UpdatedFavorites bit NULL,
	--VisitsBeforeReservation int NULL,
	--VisitsBeforeRegistration int NULL,
	--LastPointsGainDate datetime NULL,
	--DiningFormEmailOptIn bit NULL,
	--LastResoPhoneTypeID int NULL,
	--UpdatedUTC datetime NULL,
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

--*************************************************************
--** IMPORTANT: Please review any changes to this proc against:
--**	proc_UserSvc_SetCallerInfo
--**	proc_UserSvc_SetCustomerInfo
--**
--** These procs are part of a pair. 
--** They are split to make it easier to diff (for logical symmetry)
--** and for performance reasons
--*************************************************************

declare @CustID int, @CallerID int
 
select	@CustID = CustID
		,@CallerID = CallerID
from	GlobalPerson
where	_GlobalPersonID = @GlobalPersonId

if exists(select CustID from Customer where email = @email and custID != isnull(@custID,0))
begin 
	RAISERROR('Email already in use by another account',15,2) --'That email address is already in use.'
	return
end

if exists(select CallerID from Caller where LoginName = @email and CallerID != isnull(@CallerID,0))
begin
	RAISERROR('Email already in use by another account',15,2) --'That email address is already in use.'
	return
end

BEGIN TRANSACTION
	BEGIN TRY
		if @CallerID is not null
		BEGIN
			exec proc_UserSvc_SetCallerInfo 
					@CallerID,
					@Email,
					@LoginName,
					@FName,
					@LName,
					@SFname,
					@SLname,
					@Address1,
					@Address2,
					@City,
					@State,
					@ZIP,
					@Country,
					@MetroAreaID,
					@SpecialRequest
					
			exec dbo.procUpdateUserPhoneDetails
				@CallerID,
				@PhoneCountryID,
				@DayPhone,
				@MobilePhoneCountryID,
				@MobilePhone,
				1, --@IsCaller bit
				1 --@IsUpdate bit

			-- Insert CallerToken 
			IF @Hash IS NOT NULL AND @Salt IS NOT NULL AND @UserTokenTypeID IS NOT NULL
			   AND NOT EXISTS (SELECT 1 FROM CallerToken WHERE CallerID = @CallerID AND UserTokenTypeID = @UserTokenTypeID AND [Hash] = @Hash AND Salt = @Salt)	
			BEGIN	
				DELETE CallerToken WHERE CallerID = @CallerID
				Insert into CallerToken (CallerID, Hash, Salt, UserTokenTypeID)
				values (@CallerID, @Hash, @Salt, @UserTokenTypeID)
			END	
	
		END
		else
		BEGIN
			exec proc_UserSvc_SetCustomerInfo 
					@CustID,
					@Email,
					@LoginName,
					@FName,
					@LName,
					@SFname,
					@SLname,
					@Address1,
					@Address2,
					@City,
					@State,
					@ZIP,
					@Country,
					@MetroAreaID,					
					@SpecialRequest
					
			exec dbo.procUpdateUserPhoneDetails
				@CustID,
				@PhoneCountryID,
				@DayPhone,
				@MobilePhoneCountryID,
				@MobilePhone,
				0, --@IsCaller bit
				1 --@IsUpdate bit
			
			-- Insert CustomerToken 
			IF @Hash IS NOT NULL AND @Salt IS NOT NULL AND @UserTokenTypeID IS NOT NULL
			   AND NOT EXISTS (SELECT 1 FROM CustomerToken WHERE CustID = @CustID AND UserTokenTypeID = @UserTokenTypeID AND [Hash] = @Hash AND Salt = @Salt)	
			BEGIN	
				DELETE CustomerToken WHERE CustID = @CustID
				Insert into CustomerToken (CustID, Hash, Salt, UserTokenTypeID)
				values (@CustID, @Hash, @Salt, @UserTokenTypeID)
			END	
		END
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		DECLARE @Message varchar(500)
		SET	@Message = 'Error:Inserting/Updating User [' + ISNULL(ERROR_MESSAGE(),'') +']'
		RAISERROR (@Message, 16, 1)
		RETURN
	END CATCH

COMMIT TRANSACTION

GO

GRANT EXECUTE ON [UserSvc_SetCustomerInfo] TO ExecuteOnlyRole
GO

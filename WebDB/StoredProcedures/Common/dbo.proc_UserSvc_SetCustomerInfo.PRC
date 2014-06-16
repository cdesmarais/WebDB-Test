if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[proc_UserSvc_SetCustomerInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[proc_UserSvc_SetCustomerInfo]
GO

CREATE Procedure dbo.proc_UserSvc_SetCustomerInfo
 (
	@custID int,
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
	@MetroAreaID int, -- NULL,
	@Special nvarchar(1000) --(999) NULL,
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

BEGIN TRANSACTION
	BEGIN TRY
		
		update customer
		set FName = @FName,
			LName = @LName,
			SFname = @SFname,
			SLname = @SLname,
			MetroAreaID = @MetroAreaID,
			Address1 = @Address1,
			Address2 = @Address2,
			City = @City,
			State = @State,
			ZIP = @ZIP,
			Country = @Country,
			Email = @Email,
			Special = @Special,
			--Pwd = @Pwd,
			--Active = @Active,
			UpdatedUTC = GetUTCDate()
		where custid = @custid
	
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		DECLARE @Message varchar(500)
		SET	@Message = 'Error:Inserting/Updating User [' + ISNULL(ERROR_MESSAGE(),'') +']'
		RAISERROR (@Message, 16, 1)
		RETURN
	END CATCH
	
COMMIT

GO

GRANT EXECUTE ON [proc_UserSvc_SetCustomerInfo] TO ExecuteOnlyRole
GO

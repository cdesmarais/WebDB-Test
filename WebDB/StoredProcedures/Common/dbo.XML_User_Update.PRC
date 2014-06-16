if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XML_User_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XML_User_Update]
GO

CREATE  Procedure dbo.XML_User_Update
(
 @UserID int,
  @FirstName nvarchar(255),
  @LastName nvarchar(255),
  @Email nvarchar(255),
  @Password nvarchar(255),
  @PasswordQuestionID int ,
  @PasswordAnswer nvarchar(255),
  @SendAnnouncements int,
  @DayPhone nvarchar(24),
  @DefaultGeoID int,
  @CreditCardType int,
  @CreditCardNumber nvarchar(255),
  @ExpireMonth int,
  @ExpireYear int,
  @PartnerID int,
  @IsPrimary int = 1 --assume we are dealing with the primary credit card
 )
As
SET NOCOUNT ON
set transaction isolation level read uncommitted

--**************************************************************************************
--** Begin OBOSLETE LOG
--** The following will log the fact that this obsolete proc was exectured into LogDB..ErrorLog
--** This snippet can be cut and pasted in to any block of code that is thought to be obsolete
--** Embedded in WR9 2010
--**************************************************************************************
	declare @_ErrorMessage nvarchar(1000)
	set @_ErrorMessage = 'PROC called'

	declare @_objName nvarchar(1000)
	SELECT	@_objName = OBJECT_NAME(@@PROCID), 
			@_ErrorMessage = @_ErrorMessage 
							+ ': '+ @_objName
							+ '  by host: ' + rtrim(isnull(hostname, 'unknown'))
							+ '  User: ' + rtrim(isnull(loginame, 'unknown'))
	FROM	sys.sysprocesses 
	WHERE	spid = @@spid  
	exec procLogProcedureError 9, @_objName, 'OBSOLETE', @_ErrorMessage
--**************************************************************************************
--** End OBOSLETE LOG
--**************************************************************************************

Declare	@dup_UserID int
	,@n int
	,@cur_FName nvarchar(255)
	,@cur_LName nvarchar(255)
	,@cur_Email nvarchar(255)
	,@cur_SendAnnouncements int
	,@cur_DayPhone nvarchar(24)
	,@cur_DefaultGeoID int
	
SET DATEFORMAT mdy

BEGIN TRAN

Select 
@cur_FName = c.FName
,@cur_LName = c.LName
,@cur_Email = c.Email
,@cur_SendAnnouncements = c.SendAnnouncements
,@cur_DayPhone = cp.Phone
,@cur_DefaultGeoID = c.metroareaid
From Customer c
inner join CustomerPhone cp
on c.CustID = cp.CustID AND cp.IsPrimary = 1
Where c.CustID = @UserID


-- Check for null integer fields comming from the middle teir as zeroes
If @SendAnnouncements = 0 Select @SendAnnouncements = @cur_SendAnnouncements
If @DefaultGeoID = 0 Select @DefaultGeoID = @cur_DefaultGeoID

-- Ensure some other user doesn't already have this email address.
SELECT @dup_UserID = @UserID -- Set the default to the current ID.
SELECT @dup_UserID = CustID 
FROM Customer WHERE Email = @Email
IF (@dup_UserID <> @UserID) GOTO dup_email


UPDATE Customer
SET FName = ltrim(rtrim(coalesce(@FirstName,@cur_FName)))
,LName = ltrim(rtrim(coalesce(@LastName,@cur_LName)))
,EMail = ltrim(rtrim(coalesce(@Email,@cur_Email)))
,PwdQuestionID = @PasswordQuestionID
,PwdAnswer = @PasswordAnswer
,metroareaid = @DefaultGeoID
,SendAnnouncements = @SendAnnouncements
WHERE (CustID = @UserID)

UPDATE CustomerPhone
SET Phone= coalesce(@DayPhone,@cur_DayPhone)
WHERE CustID = @UserID
AND IsPrimary = 1 

IF EXISTS(Select CustID from UserOptIn with (nolock) where CustID=@UserID and MetroAreaID = @DefaultGeoID)
	UPDATE UserOptIn
		SET Insider = @SendAnnouncements, DinersChoice= @SendAnnouncements, NewHot= @SendAnnouncements, RestaurantWeek= @SendAnnouncements, Promotional= @SendAnnouncements, SpotLight= @SendAnnouncements,Product= @SendAnnouncements,UpdatedDtUTC= getutcdate()
	WHERE CustID = @UserID
		AND MetroAreaID = @DefaultGeoID
ELSE
	IF  EXISTS(SELECT CustID FROM Customer with (nolock) where CustID=@UserID AND ConsumerType <> 8)
		INSERT INTO UserOptIn (CustID, Insider,DinersChoice,NewHot,RestaurantWeek, Promotional,SpotLight, Product, MetroAreaID) 
			VALUES (@UserID,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements, @DefaultGeoID)

	COMMIT TRAN

	RETURN(0)
dup_email:
	ROLLBACK TRAN

	RAISERROR('4',16,1)
	RETURN(1)

GO


GRANT EXECUTE ON [XML_User_Update] TO ExecuteOnlyRole

GO

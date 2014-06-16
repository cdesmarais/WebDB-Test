if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Caller_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Caller_Update]
GO


CREATE PROCEDURE dbo.Concierge_Caller_Update
 (
  @UserID int,
  @FirstName nvarchar(255),
  @LastName nvarchar(255),
  @Email nvarchar(255),
  @Password nvarchar(255),
  @PasswordQuestionID int ,
  @PasswordAnswer nvarchar(255),
  @DayPhone nvarchar(24),
  @FaxPhone nvarchar(24),
  @DefaultGeoID int,
  @Notes nvarchar(255),
  @SendAnnouncements bit,
  @Default_Tab int
 )
As
SET NOCOUNT ON

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

SET DATEFORMAT mdy
SET TRAN ISOLATION LEVEL SERIALIZABLE
BEGIN TRAN

   UPDATE Caller 
		SET FName = @FirstName,
			LName = @LastName,EMail = @Email,
			PwdQuestionID = @PasswordQuestionID,
			PwdAnswer = @PasswordAnswer, 
			metroareaid = @DefaultGeoID,
			Notes = @Notes,
			SendAnnouncements = ISNULL(@SendAnnouncements,SendAnnouncements),
			SearchTypeID = @Default_Tab
   WHERE (CallerID = @UserID)
   IF @@Error <> 0  
     goto error

   UPDATE Company set FaxPhone = @FaxPhone where CompanyID = (Select CompanyID from Caller where CallerID = @UserID)
   IF @@Error <> 0  
     goto error

   UPDATE CallerPhone SET Phone= @DayPhone WHERE CallerID = @UserID AND PhoneTypeID = 6 
   IF @@Error <> 0  
     goto error
	 
		
	IF (@SendAnnouncements IS NOT NULL)
		IF EXISTS(SELECT CallerID from UserOptIn with (nolock) where CallerID=@UserID AND MetroAreaID = @DefaultGeoID)
			UPDATE UserOptin
				SET Insider = @SendAnnouncements,DinersChoice= @SendAnnouncements, NewHot= @SendAnnouncements,RestaurantWeek= @SendAnnouncements,Promotional= @SendAnnouncements, SpotLight= @SendAnnouncements, Product=@SendAnnouncements,UpdatedDtUTC=getutcdate()
			WHERE CallerID = @UserID
			AND MetroAreaID = @DefaultGeoID
		ELSE
			INSERT INTO UserOptIn (CallerID,Insider,DinersChoice,NewHot,RestaurantWeek,Promotional,SpotLight,Product,MetroAreaID)
				VALUES(@UserID,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@SendAnnouncements,@DefaultGeoID)

COMMIT TRAN
RETURN(0)

error:
Rollback Transaction
Raiserror ('7',16,1)  --'Error updating Customer profile.'
GO

GRANT EXECUTE ON [Concierge_Caller_Update] TO ExecuteOnlyRole

GO

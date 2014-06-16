if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Caller_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Caller_Update]
GO

CREATE PROCEDURE dbo.Admin_Caller_Update
 (
  @UserID int,
  @FirstName nvarchar(255),
  @LastName nvarchar(255),
  @login nvarchar(255),
  @Email nvarchar(255),
  @Password nvarchar(255),
  @DefaultGeoID int,
  @HotelID int,
  @PositionID int,
  @PartnerID int
 )
 
As
SET NOCOUNT ON
SET DATEFORMAT mdy
SET TRAN ISOLATION LEVEL SERIALIZABLE
BEGIN TRAN

 -- per TT 46378 we want to track whenever we try to insert logins and emails that don't match
	Declare @Enable int
	select @Enable = ValueInt from ValueLookup where LKey = 'Caller_Instrumentation' and LType = 'WEBSERVER'
	IF (@PositionID = 3 and @Enable = 1)
	BEGIN
		IF (@Login != @Email or @Email is null or @Login is null)
		BEGIN
		declare @ErrorMsg as nvarchar(4000)	
		set @ErrorMsg = N'Caller update login/email mismatch (callerid ' + cast(@UserID as nvarchar(255)) + ') - login: ''' 
			+ cast(ISNULL(@Login,'NULL') as nvarchar(255)) 
			+ ''', email: ''' + cast(ISNULL(@Email,'NULL') as nvarchar(255)) + ''''
		exec DNErrorAdd 423, 'Admin_Caller_Update', @ErrorMsg, 2
		END
	END

   UPDATE Caller 
   SET    FName    = @FirstName
        ,LName     = @LastName
        ,EMail         = @Email
        ,LoginName    = @login
        ,metroareaid = @DefaultGeoID
        ,CompanyID    = @HotelID
        ,PositionID   = @PositionID
        ,PartnerID    = @PartnerID
   WHERE (CallerID     = @UserID)
   IF @@Error <> 0  
     goto error

COMMIT TRAN
RETURN(0)

error:
Rollback Transaction
Raiserror ('7',16,1)  --'Error updating Customer profile.'

GO

GRANT EXECUTE ON [Admin_Caller_Update] TO ExecuteOnlyRole

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_User_ChangeEmail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_User_ChangeEmail]
GO

CREATE PROCEDURE dbo.Admin_User_ChangeEmail
(
  @CustomerOrCallerID int,
  @CustomerType int,  -- if 0, then use Customer table, else use Caller table (1 = Admin, 2 = Concierge)
  @NewEmailAddress nvarchar (75)
)
AS

BEGIN TRANSACTION

IF @CustomerType = 0
	-- the given ID is a Customer ID
	BEGIN
		UPDATE Customer 
			SET Email  = @NewEmailAddress
		WHERE CustID = @CustomerOrCallerID
		-- bail if error
		IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRANSACTION
				RETURN(-1)
			END
	END
ELSE 
	BEGIN  -- ID is either an Admin or a Concierge.  
		IF @CustomerType = 1
			BEGIN -- Admin, update both the Email and the Login
				UPDATE Caller 
					SET Email  = @NewEmailAddress,
						LoginName  = @NewEmailAddress
				WHERE CallerID = @CustomerOrCallerID
			-- bail if error
			IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRANSACTION
					RETURN(-1)
				END		
		END
		ELSE
			BEGIN -- Concierge, update just the email
				UPDATE Caller 
					SET Email  = @NewEmailAddress
				WHERE CallerID = @CustomerOrCallerID
			-- bail if error
			IF (@@ERROR <> 0)
				BEGIN
					ROLLBACK TRANSACTION
					RETURN(-1)
				END		
			END
	END

-- AOK
COMMIT TRANSACTION
RETURN(0)



GO

GRANT EXECUTE ON [Admin_User_ChangeEmail] TO ExecuteOnlyRole

GO

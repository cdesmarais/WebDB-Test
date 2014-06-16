

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_User_AddNotes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_User_AddNotes]
GO

  
CREATE PROCEDURE dbo.Admin_User_AddNotes
(  
  @CustomerOrCallerID int,  
  @CustomerType int,  -- if 0, then use CustomerNotes table, else use CallerNotes table 
  @Note nvarchar(1000),
  @UpdatedBy nvarchar(100)  
)  
AS  
  
BEGIN TRANSACTION  
  
IF @CustomerType = 0  
 -- the given ID is a Customer ID  
	BEGIN  
	 --Check Entry for this Customer ID is exist or not
	IF not exists (select CustomerID from CustomerNotes where CustomerID = @CustomerOrCallerID)
		BEGIN
			INSERT INTO CustomerNotes
				(CustomerID,Notes,UpdatedBy)
			VALUES
				(@CustomerOrCallerID,@Note,@UpdatedBy)
			
			-- bail if error  
			IF (@@ERROR <> 0)  
			BEGIN  
				ROLLBACK TRANSACTION  
				RETURN(-1)  
			END
		END
	ELSE
		BEGIN
			UPDATE CustomerNotes
			SET Notes = @Note,
				UpdatedBy = @UpdatedBy,
				UpdateDTUTC = GETUTCDATE()
			WHERE CustomerID = @CustomerOrCallerID	
			
			-- bail if error  
			IF (@@ERROR <> 0)  
			BEGIN  
				ROLLBACK TRANSACTION  
				RETURN(-1)  
			END  
		END
   END
ELSE   
	BEGIN  -- ID is either an Admin or a Concierge.    
	IF @CustomerType = 1  
		BEGIN  -- Admin, update both the Email and the Login  
			--Check Entry for this Customer ID is exist or not
			IF not exists (select CallerID from CallerNotes where CallerID = @CustomerOrCallerID)
				BEGIN
					INSERT INTO CallerNotes
						(CallerID,Notes,UpdatedBy)
					VALUES
						(@CustomerOrCallerID,@Note,@UpdatedBy)
					
					-- bail if error  
					IF (@@ERROR <> 0)  
					BEGIN  
						ROLLBACK TRANSACTION  
						RETURN(-1)  
					END
				END
			ELSE
				BEGIN
					UPDATE CallerNotes
					SET Notes = @Note,
						UpdatedBy = @UpdatedBy,
						UpdateDTUTC = GETUTCDATE()
					WHERE CallerID = @CustomerOrCallerID	
					
					-- bail if error  
					IF (@@ERROR <> 0)  
					BEGIN  
						ROLLBACK TRANSACTION  
						RETURN(-1)  
					END  
				END
		END        
	END  
  
-- OK  
COMMIT TRANSACTION  
RETURN(0)  


GO

GRANT EXECUTE ON [Admin_User_AddNotes] TO ExecuteOnlyRole

GO


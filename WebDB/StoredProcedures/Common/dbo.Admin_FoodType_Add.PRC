if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_FoodType_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_FoodType_Add]
GO




CREATE PROCEDURE dbo.Admin_FoodType_Add
 (
  @Value nvarchar(255),
  @SName nvarchar(100),
  @SFTID int = null --optional, set only if a micro-cuisine
 )
As

DECLARE @ID int

--************************
--** Retrieve the LanguageID based on the DB connection
--** Error Out if no language Found
--************************
declare @LanguageID int
exec @LanguageID = procGetDBUserLanguageID

if (@@ERROR <> 0)
	goto general_error

SET NOCOUNT ON
BEGIN TRANSACTION

INSERT INTO FoodType
 (
  FoodType,
  LanguageID,
  FoodTypeSName
 )
VALUES
 (
  @Value,
  @LanguageID,
  @SName  
 )


set @ID=scope_identity()
 
if (@@ERROR <> 0)
	goto general_error

--If the SFTID is not set, then this must be a macro cuisine, so use the FoodTypeID
if(@SFTID IS NULL)	
	SET @SFTID = @ID
	
UPDATE FoodType
SET		SFTID = @SFTID
WHERE	FoodTypeID = @ID

if (@@ERROR <> 0)
	goto general_error
		
INSERT INTO FoodTypeSearchMap
VALUES(@ID,@SFTID)	

if (@@ERROR <> 0)
	goto general_error
	


COMMIT TRANSACTION 
Return(0)


general_error:
	ROLLBACK TRANSACTION
	Return(1)



GO

GRANT EXECUTE ON [Admin_FoodType_Add] TO ExecuteOnlyRole

GO

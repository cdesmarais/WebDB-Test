if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_LargeParty_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_LargeParty_Update]
GO




CREATE PROCEDURE dbo.Admin_LargeParty_Update
(
@RestaurantID int,
 @Accepts bit=0,
 @Large_Number int,
 @Message nvarchar(999)
)

As
/*Adjusted 10/1/2003 for message schema changes*/
SET NOCOUNT ON

BEGIN TRANSACTION
 
   UPDATE Restaurant
   SET
   AcceptLargeParty = @Accepts,
   MaxLargePartyID = @Large_Number
   WHERE (RID = @RestaurantID)

   if (@@ERROR <> 0)
	goto general_error

exec dbo.DNSetCustomMessageFromName @RestaurantID,'LargeParty',@Message

   if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Admin_LargeParty_Update] TO ExecuteOnlyRole

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_TopList_Insert]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_TopList_Insert]
GO




CREATE PROCEDURE dbo.Admin_Restaurant_TopList_Insert
(
  @RestID int,
  @Rank int
)
AS
SET NOCOUNT ON

BEGIN TRANSACTION

Insert into RestaurantTopList (RID,Rank) VALUES (@RestID,@Rank)
if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)




GO

GRANT EXECUTE ON [Admin_Restaurant_TopList_Insert] TO ExecuteOnlyRole

GO

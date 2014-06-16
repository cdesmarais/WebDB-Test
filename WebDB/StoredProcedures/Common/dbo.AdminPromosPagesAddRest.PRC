
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminPromosPagesAddRest]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminPromosPagesAddRest]
GO




CREATE PROCEDURE dbo.AdminPromosPagesAddRest
(
  @PromoID int,
  @RestID int,
  @Message ntext,
  @rank int,
  @active int,
  @Lunch int,
  @Dinner int,
  @UserId int = null
)
AS
SET NOCOUNT ON


BEGIN TRANSACTION
Delete from PromoRests where RID = @RestID and PromoID =  @PromoID
if @active = 1
BEGIN
	Insert into PromoRests
		(
		RID,
		Message,
		PromoID,
		Rank,
		Lunch,
		Dinner
		)
	VALUES
		(
		@RestID,
		@Message,
		@PromoID,
		@rank,
		@Lunch,
		@Dinner
		)
END

if @@ERROR <> 0
		goto error

COMMIT TRANSACTION
Return(0)
 
error:
ROLLBACK TRANSACTION
Return(0)
GO


GRANT  EXECUTE  ON [dbo].[AdminPromosPagesAddRest]  TO [ExecuteOnlyRole]
GO


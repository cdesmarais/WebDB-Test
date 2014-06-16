

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdminPromosPagesActivateInMetro]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdminPromosPagesActivateInMetro]
GO







CREATE PROCEDURE dbo.AdminPromosPagesActivateInMetro
(
  @PromoID int,
  @MetroID int,
  @active int
)
AS
SET NOCOUNT ON



BEGIN TRANSACTION

Delete from PromoPagesToMetro where MetroID = @MetroID and PromoID =  @PromoID
if @active = 1
BEGIN
	Insert into PromoPagesToMetro
		(
		MetroID,
		PromoID
		)
	VALUES
		(
		@MetroID,
		@PromoID
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


GRANT  EXECUTE  ON [dbo].[AdminPromosPagesActivateInMetro]  TO [ExecuteOnlyRole]
GO


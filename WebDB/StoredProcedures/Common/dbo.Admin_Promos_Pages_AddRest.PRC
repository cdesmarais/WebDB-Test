if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Promos_Pages_AddRest]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Promos_Pages_AddRest]
GO

CREATE PROCEDURE dbo.Admin_Promos_Pages_AddRest
(
  @PromoID int,
  @RestID int,
  @ShortDesc nvarchar(50),
  @Message ntext,
  @Reserve nvarchar(50),
  @rank int,
  @active int
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
	ShortDesc,
	PromoID,
	Reserve,
	Rank
	)
VALUES
	(
	@RestID,
	@Message,
	@ShortDesc,
	@PromoID,
	@Reserve,
	@rank
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

GRANT EXECUTE ON [Admin_Promos_Pages_AddRest] TO ExecuteOnlyRole

GO

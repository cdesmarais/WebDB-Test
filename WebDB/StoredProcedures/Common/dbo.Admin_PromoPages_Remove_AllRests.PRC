

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_PromoPages_Remove_AllRests]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_PromoPages_Remove_AllRests]
GO

CREATE PROCEDURE dbo.Admin_PromoPages_Remove_AllRests
(
	@PromoID int
)
AS
SET NOCOUNT ON

BEGIN TRANSACTION

	Delete From PromoRests
	Where PromoID=@PromoID

if @@ERROR <> 0
		goto error

COMMIT TRANSACTION
Return(0)
 
error:
ROLLBACK TRANSACTION
Return(0)
GO


GRANT  EXECUTE  ON [dbo].[Admin_PromoPages_Remove_AllRests]  TO [ExecuteOnlyRole]
GO

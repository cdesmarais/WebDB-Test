if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Offer_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Offer_Update]
GO

CREATE Procedure dbo.Admin_Offer_Update
 (
  @Value nvarchar(255),
  @Offer_ID int
 )
As
SET NOCOUNT ON

BEGIN TRANSACTION
declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError int
declare @id int

--**********************
--** Get Language
--**********************
set @Action = 'Retrieve LanguageID'
declare @LanguageID int
exec @LanguageID = procGetDBUserLanguageID
set @DBError = @@error
if @DBError <> 0
	goto general_error


--**********************
--** Update Local
--**********************
set @Action = 'Update OfferLocal'

UPDATE OfferLocal
		SET Offer = @Value
WHERE	offerID =  @Offer_ID
AND		LanguageID = @LanguageID

set @DBError = @@error
if @DBError <> 0
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	exec procLogProcedureError 1, @ProcName, @Action, @DBError
	Return(0)
GO


GO

GRANT EXECUTE ON [Admin_Offer_Update] TO ExecuteOnlyRole

GO

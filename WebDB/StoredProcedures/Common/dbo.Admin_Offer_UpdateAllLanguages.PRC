
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Offer_UpdateAllLanguages]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Offer_UpdateAllLanguages]
GO

CREATE Procedure dbo.Admin_Offer_UpdateAllLanguages
 (
  @OfferNames nvarchar(4000),
  @LanguageIDs nvarchar(255),
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
--** Update Local
--**********************
set @Action = 'Update OfferLocal'

UPDATE OfferLocal 
SET 	Offer = [Value]
FROM	dbo.fMergeListsToTab(@LanguageIDs, @OfferNames, '#', '#')
WHERE	offerID =  @Offer_ID
AND	OfferLocal.LanguageID = [Key]

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

GRANT EXECUTE ON dbo.[Admin_Offer_UpdateAllLanguages] TO ExecuteOnlyRole

GO

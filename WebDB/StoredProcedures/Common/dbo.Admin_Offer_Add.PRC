if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Offer_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Offer_Add]
GO

CREATE Procedure dbo.Admin_Offer_Add
 (
  @Value nvarchar(255)
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
--** Insert into Master
--**********************
set @Action = 'INSERT INTO Offer'

INSERT INTO Offer
 (
  Offer
 )
VALUES
 (
  @Value
 )
set @DBError = @@error
set @id = scope_identity()
if @DBError <> 0
	goto general_error

--**********************
--** Insert into Local
--**********************
set @Action = 'INSERT INTO OfferLocal'

INSERT INTO OfferLocal
 (
	OfferID,
	LanguageID,
	Offer
 )
VALUES
 (
	@id,
	@LanguageID,
	@Value
 )
set @DBError = @@error
set @id = scope_identity()
if @DBError <> 0
	goto general_error


COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	exec procLogProcedureError 1, @ProcName, @Action, @DBError
	Return(0)
GO

GRANT EXECUTE ON [Admin_Offer_Add] TO ExecuteOnlyRole

GO

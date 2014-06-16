if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Offer_AddAllLanguages]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Offer_AddAllLanguages]
GO

CREATE Procedure dbo.Admin_Offer_AddAllLanguages
 (
  @OfferNames nvarchar(4000),
  @LanguageIDs nvarchar(255)
 )
As
SET NOCOUNT ON

BEGIN TRANSACTION
declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError int
declare @id int


--**********************
--** Create table with offer names and languages
--**********************
set @Action = 'generate temp table for offer names'

declare @OfferTab table
	(
	     offerName nvarchar(255),
	     LanguageID int
	)
insert into @OfferTab (offerName, LanguageID)
	select [Value], [Key] from dbo.fMergeListsToTab(@LanguageIDs, @OfferNames, '#', '#')

If @@Error <> 0 
   goto general_error

--**********************
--** Insert into Master
--**********************
set @Action = 'INSERT INTO Offer'

INSERT INTO Offer
 (
  Offer
 )
 select top 1 OfferName from @OfferTab order by LanguageID
 
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
	select @id,
		LanguageID,
		OfferName
	from @OfferTab

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

GRANT EXECUTE ON [Admin_Offer_AddAllLanguages] TO ExecuteOnlyRole

GO

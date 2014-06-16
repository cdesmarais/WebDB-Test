if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_MetroUpdate_Local_V2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_MetroUpdate_Local_V2]
GO

--
-- Versioned into V2 to accommodate new colums in MetroAreaLocal, so proc sig changes
-- TT 30454 mmc WR2009_R7
--
CREATE PROCEDURE dbo.Admin_MetroUpdate_Local_V2
(
  @name nvarchar(255),
  @sname nvarchar(255),
  @message nvarchar(999),
  @ID int,
  @TitleTag nvarchar(255),
  @ShortDisplayName nvarchar(50),
  @MetaDescriptionText nvarchar(255),
  @MetaKeywordText nvarchar(255)
)
AS

BEGIN TRANSACTION

declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError int


set @ProcName = 'Admin_MetroUpdate_Local'

if (@sname is null)
	set @sname = ''

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
--** Update Local Table
--**********************
set @Action = 'UPDATE MetroAreaLocal'
if exists(Select MetroareaID from MetroareaVW where metroareaID = @ID)
BEGIN
	UPDATE MetroAreaLocal
	SET
		MetroAreaName=@name,
		Message=@message,
		TitleTag=@TitleTag,
		ShortDisplayName=@ShortDisplayName,
		MetaDescriptionText = @MetaDescriptionText,
		MetaKeywordText = @MetaKeywordText
	Where	metroareaid = @ID
	and		LanguageID = @LanguageID
END
else
BEGIN
	INSERT INTO [MetroAreaLocal] (
		[MetroAreaID],
		[LanguageID],
		[MetroAreaName],
		[Message],
		[TitleTag],
		[ShortDisplayName],
		[MetroAreaSName],
	    [MetaDescriptionText],
		[MetaKeywordText]
	) 
	VALUES
	(
		@ID,
		@LanguageID,
		@name,
		@message,
		@TitleTag,
		@ShortDisplayName,
		@sname,
	    @MetaDescriptionText,
		@MetaKeywordText
	)
END


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

GRANT EXECUTE ON [Admin_MetroUpdate_Local_V2] TO ExecuteOnlyRole

GO

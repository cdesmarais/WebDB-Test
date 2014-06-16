

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_MetroUpdate_Local_V4]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_MetroUpdate_Local_V4]
GO

--
-- Versioned into V4 to accommodate new colums in MetroAreaLocal, so proc sig changes
-- TT 40942 mn WR2010_R8
--
CREATE PROCEDURE dbo.Admin_MetroUpdate_Local_V4
(
  @name nvarchar(255),
  @sname nvarchar(255),
  @message nvarchar(999),
  @ID int,
  @TitleTag nvarchar(255),
  @ShortDisplayName nvarchar(50),
  @MetaDescriptionText nvarchar(255),
  @MetaKeywordText nvarchar(255),
  @MetroTitleTag nvarchar(150),
  @SpotLightLink nvarchar(255),
  @SpotLightLinkText nvarchar(80),
  @SpotLightImage nvarchar(255)
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
		MetaKeywordText = @MetaKeywordText,
		MetroTitleTag = @MetroTitleTag,
		SpotLightLink = @SpotLightLink,
		SpotLightLinkText = @SpotLightLinkText,
		SpotLightImage = @SpotLightImage
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
		[MetaKeywordText],
		[MetroTitleTag],
		[SpotLightLink],
		[SpotLightLinkText],
		[SpotLightImage]
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
		@MetaKeywordText,
		@MetroTitleTag,
		@SpotLightLink,
		@SpotLightLinkText,
		@SpotLightImage
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

GRANT EXECUTE ON [Admin_MetroUpdate_Local_V4] TO ExecuteOnlyRole

GO

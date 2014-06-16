if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_MetroUpdate_Local3]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_MetroUpdate_Local3]
GO


CREATE PROCEDURE dbo.Admin_MetroUpdate_Local3
(
  @name nvarchar(255),
  @sname nvarchar(255),
  @message nvarchar(999),
  @ID int,
  @TitleTag nvarchar(255),
  @ShortDisplayName nvarchar(50),
  @MetroTitleTag nvarchar(126),
  @SpotlightLink nvarchar(255),
  @SpotlightLinkText nvarchar(80),
  @SpotlightImage nvarchar(255)
)
AS

BEGIN TRANSACTION

declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError int


set @ProcName = 'Admin_MetroUpdate_Local3'

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
		MetroTitleTag=@MetroTitleTag,
		SpotlightLink=@SpotlightLink,
		SpotlightLinkText=@SpotlightLinkText,
		SpotlightImage=@SpotlightImage
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
		[MetroTitleTag],
		[MetroAreaSName],
		[SpotlightLink],
		[SpotlightLinkText],
		[SpotlightImage]
	) 
	VALUES
	(
		@ID,
		@LanguageID,
		@name,
		@message,
		@TitleTag,
		@ShortDisplayName,
		@MetroTitleTag,
		@sname,
		@SpotlightLink,
		@SpotlightLinkText,
		@SpotlightImage
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

GRANT EXECUTE ON [Admin_MetroUpdate_Local3] TO ExecuteOnlyRole

GO

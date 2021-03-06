if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_MetroUpdateLocal]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_MetroUpdateLocal]
GO


CREATE PROCEDURE dbo.Admin_MetroUpdateLocal
(
  @name nvarchar(255),
  @message nvarchar(999),
  @ID int,
  @TitleTag nvarchar(255),
  @ShortDisplayName nvarchar(50)
)
AS

BEGIN TRANSACTION

declare @ProcName as nvarchar(1000)
declare @Action as nvarchar(3000)
declare @DBError int


set @ProcName = 'Admin_MetroUpdateLocal'

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
		ShortDisplayName=@ShortDisplayName
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
		[ShortDisplayName]
	) 
	VALUES
	(
		@ID,
		@LanguageID,
		@name,
		@message,
		@TitleTag,
		@ShortDisplayName
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

GRANT EXECUTE ON [Admin_MetroUpdateLocal] TO ExecuteOnlyRole

GO

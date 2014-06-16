if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FAQ_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[FAQ_Update]
GO


CREATE PROCEDURE dbo.FAQ_Update
(
  @ID int,
  @typeID int=0,
  @question nvarchar(999)=Null,
  @shortdesc nvarchar(999)=Null,
  @answer nvarchar(4000)=Null,
  @status bit,
  @UpdateID int=0
)
AS
SET NOCOUNT ON
--*****************
--** TODO: EV: Drop this proc. Uses Dead Table FAQValues
--*****************


BEGIN TRANSACTION
Declare @sort int

if @status > 0 (Select @sort=(Select Count(*) from FAQValues Where FAQTypeID = @typeID AND active > 0) + 1)
if @status = 0 (Select @sort=Null)
if (@UpdateID = 0)

    Update FAQValues
    Set FAQType_ID = @typeID,
    FAQQuestion = @question,
    FAQShortdesc = @shortdesc,
    FAQAnswer = @answer,
    active= @status
    Where FAQ_ID = @ID

if (@UpdateID > 0)
    Update FAQValues
    Set active = @status, sortorder = @sort
    Where FAQ_ID = @ID


if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)

GO

GRANT EXECUTE ON [FAQ_Update] TO ExecuteOnlyRole

GO

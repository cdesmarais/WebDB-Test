if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FAQ_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[FAQ_Add]
GO

CREATE PROCEDURE dbo.FAQ_Add
(
  @typeID int,
  @question nvarchar(999),
  @shortdesc nvarchar(999)=Null,
  @answer nvarchar(4000)=Null,
  @status bit
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

Insert Into FAQValues
(
    FAQTypeID,
    FAQquestion,
    FAQshortdesc,
    FAQanswer,
    sortorder,
    active
)
 Values
(
    @typeID,
    @question,
    @shortdesc,
    @answer,
    @sort,
    @status
)

if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)

GO

GRANT EXECUTE ON [FAQ_Add] TO ExecuteOnlyRole

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_MediaAdd]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_MediaAdd]
GO




CREATE PROCEDURE dbo.Admin_MediaAdd
(
  @mediatype int,
  @pubid int,
  @articledate datetime,
  @title nvarchar(300),
  @shortdesc nvarchar(4000),
  @longdesc text,
  @active bit,
  @retval int OUTPUT
)
AS
SET NOCOUNT ON

BEGIN TRANSACTION

INSERT INTO MediaNewsOnline
(MediaType,
PubID,
Title,
ShortDescription,
LongDescription,
ArticleDate,
active
)
VALUES
(
@mediatype,
@pubid,
@title,
@shortdesc,
@longdesc,
@articledate,
@active
)

set @retval=scope_identity()
if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Admin_MediaAdd] TO ExecuteOnlyRole

GO

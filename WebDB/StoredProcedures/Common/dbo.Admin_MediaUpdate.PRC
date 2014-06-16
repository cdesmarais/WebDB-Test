if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_MediaUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_MediaUpdate]
GO




CREATE PROCEDURE dbo.Admin_MediaUpdate
(
  @newsid int,
  @mediatype int,
  @pubid int,
  @articledate datetime,
  @title nvarchar(300),
  @shortdesc nvarchar(4000),
  @longdesc text,
  @active bit
)
AS
SET NOCOUNT ON

BEGIN TRANSACTION

UPDATE MediaNewsOnline
SET
MediaType=@mediatype,
PubID=@pubid,
Title=@title,
ShortDescription=@shortdesc,
LongDescription=@longdesc,
ArticleDate=@articledate,
active=@active
Where NewsID=@newsid

if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Admin_MediaUpdate] TO ExecuteOnlyRole

GO

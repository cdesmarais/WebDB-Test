if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Delete_Article]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Delete_Article]
GO


CREATE PROCEDURE dbo.Delete_Article
(
    @NewsID int
)

AS

Delete from MediaNewsOnline where NewsID = @NewsID


GO

GRANT EXECUTE ON [Delete_Article] TO ExecuteOnlyRole

GO

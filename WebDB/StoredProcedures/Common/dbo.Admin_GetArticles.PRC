if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetArticles]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetArticles]
GO




CREATE PROCEDURE dbo.Admin_GetArticles

(@mediatype int
 )

As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


Select NewsID as News_ID,Title
	,ShortDescription as Short_Description
	,MPName as NAME
	,ArticleDate as article_date
	,logo
	,m.active
From MedianewsonlineVW m
inner join MediaPublishers on m.PubID=MediaPublishers.PubID
Where MediaType= @mediatype
Order By ArticleDate desc

GO

GRANT EXECUTE ON [Admin_GetArticles] TO ExecuteOnlyRole

GO

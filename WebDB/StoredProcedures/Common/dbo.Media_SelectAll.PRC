if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Media_SelectAll]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Media_SelectAll]
GO


CREATE PROCEDURE dbo.Media_SelectAll
(
	@MediaType int,
	@NewsID int=0
)
AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

if (@NewsID = 0)
	Select NewsID as News_ID
		,Title
		,ShortDescription as Short_Description
		,MPName as NAME
		,ArticleDate as article_date
		,logo
		,TitleTag
		,MetaDescription
		,SiteDisplayName
	From MedianewsonlineVW m
	inner join MediaPublishers on m.PubID = MediaPublishers.PubID
	inner join [Domain] on m.DomainID =  [Domain].DomainID
	Where MediaType = @MediaType and m.active = 1
	Order By ArticleDate desc
    
if (@NewsID > 0)
	Select Title
		,ShortDescription as Short_Description
		,LongDescription as Long_Description
		,MPName as NAME
		,ArticleDate as article_date
		,logo
		,MediaType as Media_Type
		,m.PubID as Pub_ID
		,m.active
		,TitleTag
		,MetaDescription
		,SiteDisplayName
	From MedianewsonlineVW m
	inner join MediaPublishers on m.PubID = MediaPublishers.PubID
	inner join [Domain] on m.DomainID =  [Domain].DomainID
	Where NewsID = @NewsID
GO


GRANT EXECUTE ON [Media_SelectAll] TO ExecuteOnlyRole

GO

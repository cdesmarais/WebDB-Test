if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Content_GetReview]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Content_GetReview]
GO

CREATE PROCEDURE dbo.Content_GetReview
(
  @content_ID int,
  @Restaurant_ID int
)
AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT	Content.Content as Value
		,r.RName as Name
FROM		Content
inner join	RestaurantVW r
on			Content.RID = r.RID
WHERE		Content.contentID=@content_ID 
and			r.RID=@Restaurant_ID

GO

GRANT EXECUTE ON [Content_GetReview] TO ExecuteOnlyRole

GO

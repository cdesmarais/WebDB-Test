if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ExtranetViewNonRestList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ExtranetViewNonRestList]
GO

CREATE PROCEDURE dbo.ExtranetViewNonRestList
(
  @RestID nvarchar(2000)
)
AS

SET NOCOUNT ON
set transaction isolation level read uncommitted

select r.RID as restaurant_ID
,r.RName as name
from		RestaurantVW r
inner join	NeighborhoodAVW n 
on			n.neighborhoodid = r.neighborhoodid
and			n.LanguageID = r.LanguageID
where CHARINDEX(',' + CAST(r.RID AS nvarchar(5)) + ',',',' + @RestID + ',') > 0
Order By r.RID desc
,r.RName

GO

GRANT EXECUTE ON [ExtranetViewNonRestList] TO ExecuteOnlyRole

GO

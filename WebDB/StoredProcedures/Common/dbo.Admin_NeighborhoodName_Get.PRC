if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_NeighborhoodName_Get]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_NeighborhoodName_Get]
GO


CREATE PROCEDURE dbo.Admin_NeighborhoodName_Get
 (
  @Neighborhood_ID int
 )
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT		n.NbhoodName As NName
			,ma.MetroAreaName As MName
			,ma.EmailContact As email
			,'sjennings@opentable.com;cfobes@opentable.com' as emailCC
FROM		NeighborhoodVW n
Inner Join	MetroAreaAVW ma
On			n.metroareaid=ma.metroareaid
and			n.LanguageID = ma.LanguageID
WHERE		neighborhoodid = @Neighborhood_ID

GO

GRANT EXECUTE ON [Admin_NeighborhoodName_Get] TO ExecuteOnlyRole

GO

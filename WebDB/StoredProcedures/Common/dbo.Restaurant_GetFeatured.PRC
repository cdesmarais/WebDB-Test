if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_GetFeatured]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_GetFeatured]
GO

CREATE Procedure dbo.Restaurant_GetFeatured
 (
  @MetroID int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

Select		FeatureRestaurant.RID as restaurant_ID
			,ImageName as Image_Name
			,FRDesc as Description
			,r.RName as Name
from		FeatureRestaurant
inner join	RestaurantVW r 
on			FeatureRestaurant.RID = r.RID
where		FeatureRestaurant.MetroArea = @MetroID

GO

GRANT EXECUTE ON [Restaurant_GetFeatured] TO ExecuteOnlyRole

GO

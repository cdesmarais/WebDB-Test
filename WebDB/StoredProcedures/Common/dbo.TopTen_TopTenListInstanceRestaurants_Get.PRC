if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TopTen_TopTenListInstanceRestaurants_Get]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TopTen_TopTenListInstanceRestaurants_Get]
GO


CREATE PROCEDURE [dbo].[TopTen_TopTenListInstanceRestaurants_Get]
(
    @MetroAreaID int,
    @TopTenListID int
)
As

SET NOCOUNT ON
set transaction isolation level read uncommitted


Select 
		TTLI.TopTenListInstanceID,
		TTL.TopTenListID,
		Rest.RName,
		COALESCE(TTL.ListNameOverride,TTLT.ListName) as ListNameOverride,
		TTL.MetroAreaID,
		Metro.MetroAreaName,
		TTLR.RID, 
		TTLR.Rank,              
		0 As Suppressed,
		TTIJ.CreateDate,
		TTL.LastModified,
		TTL.LastModifiedBy,
		TTL.MediaStore_FeedListID
			
from	TopTenImportJob TTIJ 
		inner join TopTenListInstance TTLI on TTIJ.TopTenImportJobID = TTLI.TopTenImportJobID
		inner join TopTenList TTL on TTLI.TopTenListID = TTL.TopTenListID 
		inner join TopTenListType TTLT on TTL.TopTenListTypeID = TTLT.TopTenListTypeID           
		inner join MetroAreaVW Metro on TTL.MetroAreaID = Metro.MetroAreaID			
		inner join TopTenListRestaurant TTLR on TTLI.TopTenListInstanceID = TTLR.TopTenListInstanceID
		inner join RestaurantVW Rest on TTLR.RID = Rest.RID
		left join TopTenListRestaurantSuppression TTLRS on Rest.RID = TTLRS.RID and TTLI.TopTenListID = TTLRS.TopTenListID               
   
where	TTIJ.Status = 1 -- only active jobs
		and TTLI.TopTenListID = @TopTenListID
		and TTL.MetroAreaID = @MetroAreaID
		and TTLRS.RID is null -- exclude suppressed restaurants

union all

 --Get ONLY suppressed restaurants for this list
Select 
		COALESCE(TTLI.TopTenListInstanceID,0) as TopTenListInstanceID,
		TTL.TopTenListID,
		Rest.RName,
		COALESCE(TTL.ListNameOverride,TTLT.ListName) as ListNameOverride,
		TTL.MetroAreaID,
		Metro.MetroAreaName,
		Rest.RID, 
		COALESCE(ttlr.Rank,NULL) as Rank,              
		1 As Suppressed,
		COALESCE(TTIJ.CreateDate,GETDATE()) as CreateDate,
		TTL.LastModified,
		TTL.LastModifiedBy,
		TTL.MediaStore_FeedListID
			
from	TopTenListRestaurantSuppression TTLRS
		inner join TopTenList TTL on TTLRS.TopTenListID = TTL.TopTenListID 	
		inner join TopTenListType TTLT on TTL.TopTenListTypeID = TTLT.TopTenListTypeID           
		inner join MetroAreaVW Metro on TTL.MetroAreaID = Metro.MetroAreaID					
		inner join RestaurantVW Rest on TTLRS.RID = Rest.RID
		left join TopTenListInstance TTLI on TTLRS.TopTenListID = TTLI.TopTenListID
		left join TopTenImportJob TTIJ on TTLI.TopTenImportJobID = TTIJ.TopTenImportJobID 
		left join TopTenListRestaurant TTLR on TTLRS.RID = TTLR.RID and TTLI.TopTenListInstanceID = TTLR.TopTenListInstanceID
  
where	TTL.TopTenListID = @TopTenListID
		and TTL.MetroAreaID = @MetroAreaID
		and (TTIJ.Status = 1 OR TTIJ.Status is null)


order by	Suppressed ASC, Rank ASC, Rest.RName ASC


GO

GRANT EXECUTE ON [dbo].[TopTen_TopTenListInstanceRestaurants_Get] TO ExecuteOnlyRole

GO


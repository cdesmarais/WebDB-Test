if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNAddHotelRestaurants]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNAddHotelRestaurants]
GO


CREATE PROCEDURE dbo.DNAddHotelRestaurants
   (
      @HotelID int,
      @Restaurants varchar(8000)
   )
As

SET NOCOUNT ON

Insert into 	CompanyNonRestaurants 
		(
			HotelID, 
			RID
		)
Select 
	@HotelID as HotelID, 
	RID 
from 	fIDStrToTab(@Restaurants, ',') rlist
left 	outer join CompanyNonRestaurants 
on 	rlist.id = CompanyNonRestaurants.rid
where 	CompanyNonRestaurants.rid is null

GO


GRANT EXECUTE ON [DNAddHotelRestaurants] TO ExecuteOnlyRole

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Company_Excluded_Restaurants]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Company_Excluded_Restaurants]
GO


CREATE PROCEDURE dbo.Admin_Company_Excluded_Restaurants
(
	@Company_ID int
)
As
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @countRec int
	
	
	select		cn.HotelID, r.RID, r.RName,lcn.UserName 
	from		CompanyNonrestaurants cn
	inner join	RestaurantVW r		
	on			r.RID = cn.RID
	inner join	LogCompanyNonRestaurants lcn
	on			cn.HotelID = lcn.HotelID
	and			cn.RID = lcn.RID
	where		cn.HotelID =  @Company_ID	

	if (@@ERROR <> 0)
		goto general_error



general_error:	
	Return(0)

GO

GRANT EXECUTE ON [Admin_Company_Excluded_Restaurants] TO ExecuteOnlyRole

GO


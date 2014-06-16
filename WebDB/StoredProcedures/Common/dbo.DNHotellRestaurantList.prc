if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNHotellRestaurantList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNHotellRestaurantList]
GO


CREATE PROCEDURE dbo.DNHotellRestaurantList
(
	@CompanyID int
)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


	--************************
	--** Return Restaurants associated with all resos made by the company.
	--************************
	--*****************************
	--** Retrireves history using RestaurantVW
	--** Histroy will only include restaurants in a language supported by the domain / website of the caller
	--*****************************
	
	select r.rid, 
		r.Rname,
		r.RSName
	from RestaurantVW r 
	inner join AGG_hotelRestaurantList Res
	on	r.RID = res.RID 
	where Res.companyID =@companyID
	order by Rname


GO


GRANT EXECUTE ON [DNHotellRestaurantList] TO ExecuteOnlyRole

GO

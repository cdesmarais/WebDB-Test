if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobUpdateHotelRestaurantList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobUpdateHotelRestaurantList]
GO


CREATE PROCEDURE dbo.JobUpdateHotelRestaurantList

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


	--************************
	--** Insert Restaurants associated with all resos made by the company.
	--************************

	--Select restaurant list into a temporary table first (reduce locking time)
	select companyID, rid 
	into #HotelRestaurantList 
	from Reservation
	where companyID is not NULL
	group by companyID, rid
	
	
	Begin Transaction
	Truncate table AGG_HotelRestaurantList 

	Insert into AGG_HotelRestaurantList 
	(companyID, RID)
	select companyID, rid
	from #HotelRestaurantList 

	if (select count(*) from AGG_HotelRestaurantList)>0 
			commit Transaction
	else	Rollback Transaction	

	Drop table #HotelRestaurantList 

GO


GRANT EXECUTE ON [JobUpdateHotelRestaurantList] TO ExecuteOnlyRole

GO

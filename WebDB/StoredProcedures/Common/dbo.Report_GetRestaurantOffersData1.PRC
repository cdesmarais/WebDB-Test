

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_GetRestaurantOffersData1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_GetRestaurantOffersData1]
go

create procedure dbo.Report_GetRestaurantOffersData1
as  
	
	--***************************************************************************************
	--** This stored proc returns Restaurant Offers, Cuisine and other Restaurant information
	--** for restaurants in regional WebDBs.
	--** This info is used to create a report by the PJR job 'OffersReport'.
	--** Content owned by India team, please notify asaxena@opentable.com if changing.
	--***************************************************************************************

	select
		RestaurantName
		,RID
		,CuisineType
		,OfferType
		,OfferDescription
		,StartDate
		,StartTime
		,EndDate
		,EndTime
		,Metro	
		,Region		
		,Neighborhood 		
		,ZipCode
		,RestaurantPhoto
		,Price
	 from 
		OffersReportVW
	 order by
		RestaurantName asc, OfferType asc, OfferDescription asc

go

grant execute on [Report_GetRestaurantOffersData1] TO ExecuteOnlyRole

go


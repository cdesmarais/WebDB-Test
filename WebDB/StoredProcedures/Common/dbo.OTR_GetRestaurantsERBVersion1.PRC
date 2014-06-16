

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTR_GetRestaurantsERBVersion1]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTR_GetRestaurantsERBVersion1]
go

create procedure dbo.OTR_GetRestaurantsERBVersion1
as  
/* 
	Stored procedure is used to cache ERB version of restaurants from regional WebDBs in OTR website.
	OTR uses restaurant's ERB version as a criteria to determine whether to display 
	the splash page for Credit Card Admin feature or not. (Currently,	Splash page has been deprecated)
	However, caching of ERB Versions still exists.
	Content owned by India team, please notify asaxena@opentable.com if changing.
*/
	select
		RID as WebID
		,ERBVersion collate sql_latin1_general_cp1_cs_as as ERBVersion
	from	
		ERBRestaurantVW
go

GRANT EXECUTE ON [OTR_GetRestaurantsERBVersion1] TO ExecuteOnlyRole
go


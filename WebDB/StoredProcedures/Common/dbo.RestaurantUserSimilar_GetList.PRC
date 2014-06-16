if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantUserSimilar_GetList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantUserSimilar_GetList]
GO

CREATE Procedure dbo.RestaurantUserSimilar_GetList
as
/******************************************************************************
Procedure iterates through all Restaurants in Restaurant table
and produces a list of the top 10 nearest restaurants for each restaurant

Format of results is:
<RID_Source> <RID/Number of resos,RID/Number of resos,RID/Number of resos>

Where <RID_Source> is the RID of the restuarant tht the distance list is relative too

<RID/Number of resos, ...> Is a comma deliited list in order of most reserved
					RID is the nearby restaurant
					Number of resos: Number of reservations made by people 
								who also ate at RID
******************************************************************************/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

begin

	select rid as rid, SimilarList as recommended
	from RestaurantUserSimilar
	order by rid

end

GO




GRANT EXECUTE ON [RestaurantUserSimilar_GetList] TO ExecuteOnlyRole

GO

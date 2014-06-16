if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].RnR_GetMetroDFFInfoForRest') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].RnR_GetMetroDFFInfoForRest
go

/*
This SP is called from OTR to indentify the metro of the given restaurant
and also DFFStartDate for the metro; This SP is used for BV Integration.
Content owned by India team,
please notify asaxena@opentable.com if changing.
*/


create procedure [dbo].RnR_GetMetroDFFInfoForRest
(
	@parWebID int
) 
as
begin
	-- Get Metro from Restaurant - NHood and then MetroArea
	select 
			rest.RID as WebID
			,NBH.MetroAreaID
			,COALESCE(MA.dffstartdt, dateadd(Day, -1, getDate())) as DFFStartDT

	from 
			RestaurantVW rest 
			inner join NeighborhoodAVW NBH     
			on rest.NeighborhoodID = NBH.NeighborhoodID  
			and NBH.LanguageID = Rest.LanguageID   
  
			inner join MetroAreaAVW MA  
			on NBH.MetroAreaID = MA.MetroAreaID  
			and MA.LanguageID = Rest.LanguageID    


	where 
			rest.NeighborhoodID = NBH.NeighborhoodID 
			and MA.MetroAreaID = NBH.MetroAreaID
			and rest.RID = @parWebID
end
go

grant execute on RnR_GetMetroDFFInfoForRest to ExecuteOnlyRole
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procAreTopTenListsGenerated]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procAreTopTenListsGenerated]
go

CREATE procedure [dbo].[procAreTopTenListsGenerated]
(
     @metroareaid int = null
	,@macroid int = null
    ,@cuisineid	int = null
)
as

	if exists(
		select 	toptenlistid 
		from 	toptenlist
		where	metroareaid = isnull(@metroareaid, metroareaid)
		and		isnull(cuisineid,-1) = isnull(@cuisineid, -1)
		and		isnull(macroid,-1) = isnull(@macroid, -1)
		)
	begin
		return 1
	end
	
	else
		return 0
	
	
go

grant execute on [procAreTopTenListsGenerated] TO ExecuteOnlyRole

GO

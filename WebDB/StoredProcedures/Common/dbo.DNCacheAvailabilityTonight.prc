if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheAvailabilityTonight]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheAvailabilityTonight]
go

create procedure dbo.DNCacheAvailabilityTonight 
as 
begin

	set transaction isolation level read uncommitted
	set nocount on

	select		 atr.rid
				,nb.MetroAreaID
				,nb.MacroID
				,isnull(atr.AvailableTonightMetroRank, -1)	MetroRank
				,isnull(atr.AvailableTonightMacroRank, -1)	MacroRank
	from		AvailableTonightRanking atr
	inner join	Restaurant r
	on			r.rid = atr.rid
	inner join	Neighborhood nb
	on			nb.NeighborhoodID = r.NeighborhoodID
	order by	 nb.MetroAreaID, nb.MacroID

end 
go
	


GRANT EXECUTE ON [DNCacheAvailabilityTonight] TO ExecuteOnlyRole
go

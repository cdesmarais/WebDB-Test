if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobRankRestaurantsForAvailabilityTonightEUandAsia]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobRankRestaurantsForAvailabilityTonightEUandAsia]
go

create procedure dbo.JobRankRestaurantsForAvailabilityTonightEUandAsia 
as 
begin

	set transaction isolation level read uncommitted
	set nocount on
	
	declare @NumRestInRotation int
	
	declare @debug bit
	set @debug = 0
	
	---------------------------------------------
	-- Get config options from valuelookup table
	---------------------------------------------			
	select @NumRestInRotation = ValueInt 
	from ValueLookup 
	where LKey = 'AT_NumRestInRotation'
	and LType = 'WEBSERVER'

	set @NumRestInRotation = isnull( @NumRestInRotation, 50 )  -- default if not found
	if @debug = 1 print '@NumRestInRotation: ' + cast( @NumRestInRotation as nvarchar ) 

	--Refresh the table from the most booked data
	begin tran
	
	delete AvailableTonightRanking
	
	if (@@error != 0)
		goto on_error
	
	--Insert the data
	insert			AvailableTonightRanking
	select			coalesce(a.RID,b.RID) RID,
					a.RIDRank,
					b.MacroRank,
					0
	from (
		--Metro Most Booked Lists
		select			RID, 
						row_number() over( partition by ttr.MetroAreaID order by Rank) RIDRank
		from			TopTenRestaurantVW ttr
		inner join		TopTenListInstance ttli
		on				ttr.TopTenListInstanceID = ttli.TopTenListInstanceID
		inner join		TopTenList ttl
		on				ttli.TopTenListID = ttl.TopTenListID
		where			ttl.TopTenListTypeID = 1 --Most Booked
		and				ttl.MacroID is null		
		) a
		full outer join
		(
		--Macro Most Booked Lists
		select			ttr.RID,
						row_number() over (partition by ttl.MacroID order by Rank) MacroRank
		from			TopTenRestaurantVW ttr
		inner join		TopTenListInstance ttli
		on				ttr.TopTenListInstanceID = ttli.TopTenListInstanceID
		inner join		TopTenList ttl
		on				ttli.TopTenListID = ttl.TopTenListID
		inner join		RestaurantVW r
		on				ttr.RID = r.RID
		inner join		NeighborhoodVW n
		on				r.NeighborhoodID = n.NeighborhoodID
		and				ttl.MacroID = n.MacroID
		where			ttl.TopTenListTypeID = 1 --Most Booked
		and				ttl.MacroID is not null
		) b
	on				a.RID = b.RID 								
	where			(	a.RIDRank <= @NumRestInRotation or 
						b.MacroRank <= @NumRestInRotation
					)
	
	if (@@error != 0)
		goto on_error
	
	commit
	goto on_complete
	
on_error:	
	rollback
	raiserror('Failed to update Availability Tonight Ranking',16,1)
	
on_complete:

end
go

GRANT EXECUTE ON [JobRankRestaurantsForAvailabilityTonightEUandAsia] TO ExecuteOnlyRole
go


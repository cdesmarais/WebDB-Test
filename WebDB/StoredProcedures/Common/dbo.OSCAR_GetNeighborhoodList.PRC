if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OSCAR_GetNeighborhoodList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OSCAR_GetNeighborhoodList]
go

create procedure [dbo].[OSCAR_GetNeighborhoodList]
( 
	@CurrMaxRowVersionDB varbinary(16)
	,@MetroAreaRegion varchar(50)
)
as

	/*
		This proc gets the list of neighborhoods that have been added\modified
		since the last Scheduled Task run.
		Content owned by India team. Please notify asaxena@opentable.com, if changing.
	*/
	select
		NeighborhoodID
		,NbhoodName as NeighborhoodName
		,MetroAreaID as MetroID	
		,Active
		,ChangeRowVersion
		,@MetroAreaRegion as 'MetroAreaRegion'
	from 
		NeighborhoodVW		
	where
		-- coalesce is required for the first run when RowVersions will be null
		coalesce(ChangeRowVersion, 0x00000000) > coalesce(@CurrMaxRowVersionDB, 0x00000000)
	order by ChangeRowVersion asc
	
go

grant execute on [OSCAR_GetNeighborhoodList] to ExecuteOnlyRole

go


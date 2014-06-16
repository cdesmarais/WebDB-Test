

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OSCAR_GetMetroAreaList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OSCAR_GetMetroAreaList]
go

create procedure [dbo].[OSCAR_GetMetroAreaList]
( 
	@CurrMaxRowVersionDB varbinary(16)
	,@MetroAreaRegion varchar(50)
)
as

	/*
		This proc gets the list of metro areas that have been added\modified
		since the last Scheduled Task run.
		Content owned by India team. Please notify asaxena@opentable.com, if changing.
	*/
	select
		MetroAreaID
		,MetroAreaName
		,CountryCode	
		,Active
		,ChangeRowVersion
		,@MetroAreaRegion as 'MetroAreaRegion'
	from 
		OSCARMetroAreaVW		
	where
		-- coalesce is required for the first run when RowVersions will be null
		coalesce(ChangeRowVersion, 0x00000000) > coalesce(@CurrMaxRowVersionDB, 0x00000000)
	order by ChangeRowVersion asc
	
go

grant execute on [OSCAR_GetMetroAreaList] to ExecuteOnlyRole

go


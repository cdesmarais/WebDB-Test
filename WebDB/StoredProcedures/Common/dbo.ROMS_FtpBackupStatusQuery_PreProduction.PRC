if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ROMS_FtpBackupStatusQuery_PreProduction]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ROMS_FtpBackupStatusQuery_PreProduction]
GO


CREATE proc dbo.ROMS_FtpBackupStatusQuery_PreProduction
as
	--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	set nocount on 
	set transaction isolation level read uncommitted
	declare	 @rowcount  int
			,@error     int
			,@rc        int
	--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

	select		 coalesce(roa.AccountName,'00000000')	'AcctName'
				,r.RName								'RestName'
				,r.RID									'RestID'
				,r.RestStateID							'RestState'
				,rs.RState								'RestStateName'
				,r.IsReachable							'IsReachable'
				,er.ProductID							'ProductID'
				,rd.AdToolStatusChangeDate				'LastStatusChange'
	from		RestaurantVW r
	inner join	ERBRestaurant er
	on			er.RID				= r.RID
	inner join	RestaurantState rs
	on			rs.RestStateID		= r.RestStateID
	inner join	NeighborhoodAVW n
	on			n.NeighborhoodID	= r.NeighborhoodID
	and			n.LanguageID		= r.LanguageID
	inner join	MetroAreaAVW ma
	on			ma.MetroAreaID		= n.MetroAreaID
	and			ma.LanguageID		= r.LanguageID
	inner join	yellowstone.god.dbo.Restaurants rt
	on			rt.WebID			= cast(r.RID as nvarchar)
	inner join	yellowstone.god.dbo.RestDSL rd
	on			rd.RestID			= rt.RestaurantID
	left join	(
					select		roa.RestID, roa.AccountName
					from		yellowstone.god.dbo.RestOSAccount roa
					inner join	yellowstone.god.dbo.OTStdAccount osa
					on			osa.SAID			= roa.OTStdAccount
					where		osa.OSAccountType	= 2 -- FTP
				) roa
	on			roa.RestID			= rt.RestaurantID
	where		ma.Active			= 1 -- Active metro
	and			r.RestStateID		!= 4 -- Not inactive
	and			r.Allotment			!= 1 -- Not allotment
--	and			rt.RestaurantStatus	not in (4,5)
--	and			roa.AccountName		is not null
	order by	AcctName

return 0
GO

GRANT EXECUTE ON [ROMS_FtpBackupStatusQuery_PreProduction] TO ExecuteOnlyRole
GO

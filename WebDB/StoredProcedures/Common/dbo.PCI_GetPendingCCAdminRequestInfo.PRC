

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PCI_GetPendingCCAdminRequestInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PCI_GetPendingCCAdminRequestInfo]
go

create procedure dbo.PCI_GetPendingCCAdminRequestInfo
(
	@nDaysThreshold int -- Days threshold to check if CC admin request expired
)
as  
/*
	Stored procedure to get list of all pending and disabled accounts. 
	It also tells if request is expired or not based on daysThresold value specified.
	This procedure is used by OTService.
*/

	select		 
		restGod.RestaurantId
				,restWebDB.RID as 'WebId'
				,restGod.CCMerchantId
				,restGod.CCUserId
				,restGod.CCAccountStatusId
				-- If date of cc admin submission > day thresold specified then set IsExpired flag to 1 else 0
				-- Only date part is considered for comparision
		,case
			when datediff(dd, restGod.ModifiedDTUTC,GETUTCDATE()) > @nDaysThreshold 
				then 1
			else 0
		 end as 'IsExpired'
	from
		YELLOWSTONE.GOD.dbo.Restaurants restGod
	inner join
		Restaurant restWebDB
	on
		restWebDB.RID = CAST(restGod.WebId as int)
	where
		ISNUMERIC(restGod.WebId) = 1
	and
		restGod.CCAccountStatusId in (3, 5) -- (Pending, Disabled)
go


GRANT EXECUTE ON [PCI_GetPendingCCAdminRequestInfo] TO ExecuteOnlyRole
go



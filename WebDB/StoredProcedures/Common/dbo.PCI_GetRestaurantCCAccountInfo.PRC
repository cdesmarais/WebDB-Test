if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PCI_GetRestaurantCCAccountInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PCI_GetRestaurantCCAccountInfo]
go

create procedure dbo.PCI_GetRestaurantCCAccountInfo
(  
	@RID int		
)  
as  
/*
	Stored procedure to get CC account info of Restaurant.
*/

	select		 ast.CCAccountStatusId
				,ast.CCAccountStatus
				,r.CCMerchantId
				,r.CCUserId 
	from		Restaurant r
	inner join	CCAccountStatusTypes ast
	on			ast.CCAccountStatusId = r.CCAccountStatusId
	where		RID = @RID
go

GRANT EXECUTE ON [PCI_GetRestaurantCCAccountInfo] TO ExecuteOnlyRole
go

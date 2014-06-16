

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PD_GetConfirmationEmailInfoByRequestId]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PD_GetConfirmationEmailInfoByRequestId]
go

create procedure dbo.PD_GetConfirmationEmailInfoByRequestId
(
	@RequestId int	
)
 
as  

/* 
	Private Dining : Stored procedure to get Confirmation Email information sent from CHARM.
	Content owned by India team, please notify asaxena@opentable.com if changing.
*/

	select 
		UpdatedBy
		,UpdatedValues
		,rest.City as RestaurantCity
		,SubmittedFromOTR 	
	from 
		PrivateDiningUpdateLog plog
	
		inner Join RestaurantVW rest
		on plog.RID = rest.RID
	
	where 
		RequestId = @RequestId 
		and IsSubmitted = 1
		and ApprovedDTUTC is not null		
	order by 
		UpdateLogDTUTC desc
	
go
	
GRANT EXECUTE ON [PD_GetConfirmationEmailInfoByRequestId] TO ExecuteOnlyRole
go





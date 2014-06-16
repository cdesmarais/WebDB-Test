

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PD_GetPendingRequests]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PD_GetPendingRequests]
go

create procedure dbo.PD_GetPendingRequests
 
as  

/* 
	Private Dining : Stored procedure to get all pending requests.  
	Content owned by India team, please notify asaxena@opentable.com if changing.
*/

	select		
		distinct
		pd.RID
		,rest.RName
		,SubmittedBy
		,dbo.fConvertFromUTC(pd.ModifiedDTUTC,4)as ModifiedDatePST /* Get Modified date in PST format. */
		,rg.GroupName as GroupName
		,RequestId
		,MA.MetroAreaName as MetroAreaName
		,pd.IsNewPremiumRequest as IsNewPremiumRequest 
		
	from
		PrivateDiningDraftVW pd

		inner join RestaurantVW rest
		on pd.RID = rest.RID
		
		inner join NeighborhoodAVW NBH     
		on rest.NeighborhoodID = NBH.NeighborhoodID  
		and NBH.LanguageID = Rest.LanguageID   
  
		inner join MetroAreaAVW MA  
		on NBH.MetroAreaID = MA.MetroAreaID  
		and MA.LanguageID = Rest.LanguageID   
		
		left outer join RestaurantToGroup r2g
		on r2g.RID = rest.RID
		and r2g.GID != -1 /* Ignore the Group mapped to Group Id -1 */
		
		left outer join RestaurantGroup rg
		on r2g.GID = rg.GID
	where
		pd.ISDraftSubmitted = 1 /* Only Get the pending request */

	order by 
		ModifiedDatePST asc
	
go

GRANT EXECUTE ON [PD_GetPendingRequests] TO ExecuteOnlyRole
go






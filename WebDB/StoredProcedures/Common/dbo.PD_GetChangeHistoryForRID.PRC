

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PD_GetChangeHistoryForRID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PD_GetChangeHistoryForRID]
go

create procedure dbo.PD_GetChangeHistoryForRID
(
	@RID int
)
 
as  

/* 
	Private Dining : Stored procedure to get Private Dining Change history.
	Content owned by India team, please notify asaxena@opentable.com if changing.
*/

select
	PDLogId 
	,pdlog.RequestId	/* RequestId will be null for changes made from CHARM.  */
	,pdlog.RID
	,rest.RName
	,dbo.fConvertFromUTC(pdlog.UpdateLogDTUTC,4)as DraftSubmitDatePST
	,pdlog.UpdatedBy as DraftSubmittedBy
	
	/* Either request is going to be Approved or Reject so getting only required date  */
	,case 
		when pdlog.ApprovedDTUTC is not null then dbo.fConvertFromUTC(pdlog.ApprovedDTUTC,4)
		else dbo.fConvertFromUTC(pdlog.RejectedDTUTC,4)
	 end as ApprovedRejectedDatePST 
	 
	 /* Either request is going to be Approved or Reject so getting only required person info  */
	,case 
		when pdlog.ApprovedBy is not null then pdlog.ApprovedBy
		else pdlog.RejectedBy
	 end  as ApprovedRejectedBy	
	,UpdatedValues as UpdatedValuesXML
	,SubmittedFromOTR
	
	/* If action is null it means it's requested from OTR for apporval.*/
	,case 
		when pdlog.Action is null then
			'Draft'
		else pdlog.Action		
	end as Action
from
	PrivateDiningUpdateLog pdlog
	
	inner join RestaurantVW rest
	on pdlog.RID = rest.RID	
where
	pdlog.RID = @RID
	and IsSubmitted = 1 /* Exclude the changes which are only previewed in OTR. */ 
order by
	DraftSubmitDatePST desc

	
go

GRANT EXECUTE ON [PD_GetChangeHistoryForRID] TO ExecuteOnlyRole
go





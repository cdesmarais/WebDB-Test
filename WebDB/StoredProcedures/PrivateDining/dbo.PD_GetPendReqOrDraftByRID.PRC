


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PD_GetPendReqOrDraftByRID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PD_GetPendReqOrDraftByRID]
GO       
        
CREATE  procedure dbo.PD_GetPendReqOrDraftByRID            
(            
	@RID int             
)            
as          
/*               
 Private Dining : Stored procedure to get Private Dining draft or 
 Pending request information for the restaurant which one is latest.                
*/     

	declare @bIsNewPremiumRequest bit 
	
	set @bIsNewPremiumRequest = 0

	select   
		@bIsNewPremiumRequest = isnull(EnableNewPremiumRequest,0)  
	from  
		PDTracking where RID=@RID;
            
	select  top 5            
			pdi.RequestId              
			,RID              
			,PrivatePartyContact              
			,LargestCapacity              
			,PrivateDiningMenu              
			,PrivatePartyEmail              
			,PrivatePartyPhone              
			,ThumbnailImageID              
			,ThumbnailImage              
			,PrivateDiningThumbnail              
			,PartyShortDesc              
			,PartyLongDesc              
			,PremiumEnabled              
			,pdi.ModifiedDTUTC              
			,pdi.SubmittedBy              
			,RoomName              
			,RoomDescription              
			,PrivateRoomImageId              
			,RoomImage              
			,ImageName              
			,SeatedSize              
			,StandingSize              
			,ListingOrder              
			,Active              
			,PDChangeMask              
			,RoomChangeMask              
			,pdi.IsPDDraft              
			,pdi.LanguageID             
			,pdi.ISDraftSubmitted          
			,@bIsNewPremiumRequest as IsNewPremiumRequest
	from               
			PrivateDiningDraftVW pdi              
			left outer join PrivateDiningRoomDraftVW pdr              
			on pdi.RequestId = pdr.RequestId              
	                  
	where               
			RID = @RID              
			order by ModifiedDTUTC desc   
GO

GRANT EXECUTE ON [PD_GetPendReqOrDraftByRID] TO ExecuteOnlyRole

GO






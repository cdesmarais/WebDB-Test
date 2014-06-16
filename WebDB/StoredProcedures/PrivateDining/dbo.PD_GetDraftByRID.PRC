

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PD_GetDraftByRID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PD_GetDraftByRID]
go

create procedure dbo.PD_GetDraftByRID
(
	@RID int	
)
 
as  

/* 
	Private Dining : Stored procedure to get Private Dining draft for a restaurant.  
	Content owned by India team, please notify asaxena@opentable.com if changing.
*/
			select
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
			from 
				PrivateDiningDraftVW pdi
				
				left outer join PrivateDiningRoomDraftVW pdr
				on pdi.RequestId = pdr.RequestId
				
			where 
				RID = @RID
				and ISDraftSubmitted = 1
			order by ListingOrder
	
go

GRANT EXECUTE ON [PD_GetDraftByRID] TO ExecuteOnlyRole
go




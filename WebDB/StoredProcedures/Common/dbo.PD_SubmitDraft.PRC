


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PD_SubmitDraft]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PD_SubmitDraft]
go

create procedure dbo.PD_SubmitDraft
(
	@RID int

	,@RoomName1 nvarchar(100)  
	,@RoomDesc1 nvarchar(500)  
	,@SeatedSize1 int  
	,@StandingSize1 int  
	,@RoomImageID1 int 
	,@RoomImageName1 nvarchar(100) 
	,@ListingOrder1 int  
	,@RoomChangeMask1 int
	,@Active1 bit  
   
	,@RoomName2 nvarchar(100)  
	,@RoomDesc2 nvarchar(500)  
	,@SeatedSize2 int  
	,@StandingSize2 int  
	,@RoomImageID2 int 
	,@RoomImageName2 nvarchar(100)  
	,@ListingOrder2 int  
	,@RoomChangeMask2 int
	,@Active2 bit  
   
	,@RoomName3 nvarchar(100)  
	,@RoomDesc3 nvarchar(500)  
	,@SeatedSize3 int  
	,@StandingSize3 int  
	,@RoomImageID3 int  
	,@RoomImageName3 nvarchar(100) 
	,@ListingOrder3 int  
	,@RoomChangeMask3 int
	,@Active3 bit  
   
	,@RoomName4 nvarchar(100)  
	,@RoomDesc4 nvarchar(500)  
	,@SeatedSize4 int  
	,@StandingSize4 int  
	,@RoomImageID4 int 
	,@RoomImageName4 nvarchar(100)  
	,@ListingOrder4 int  
	,@RoomChangeMask4 int
	,@Active4 bit  
   
	,@RoomName5 nvarchar(100)  
	,@RoomDesc5 nvarchar(500)  
	,@SeatedSize5 int  
	,@StandingSize5 int  
	,@RoomImageID5 int  
	,@RoomImageName5 nvarchar(100)   
	,@ListingOrder5 int  
	,@RoomChangeMask5 int	
	,@Active5 bit  

	,@PrivatePartyContact nvarchar(50)
	,@LargestCapacity int
	,@PrivateDiningMenuURL nvarchar(500)
	,@PrivatePartyEmail nvarchar(510)
	,@PrivatePartyPhone nvarchar(50)
	,@PrivateDiningThumbnailImageID int
	,@PrivateDiningThumbnailImageName nvarchar(100)
	,@PrivatePartyShortDescription nvarchar(1000)
	,@PrivatePartyLongDescription nvarchar(1000)
	,@PDChangeMask int
	,@SubmittedBy nvarchar(500)
	,@PremiumEnabled bit
	,@LanguageId int
	,@PDPreviewLogID int	
)
 
as  

/* 
	Private Dining : Stored procedure to submit draft Private Dining information.  
	Content owned by India team, please notify asaxena@opentable.com if changing.
	
	Deprecated
*/

go

GRANT EXECUTE ON [PD_SubmitDraft] TO ExecuteOnlyRole
go




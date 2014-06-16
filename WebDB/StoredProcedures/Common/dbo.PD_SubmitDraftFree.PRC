

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PD_SubmitDraftFree]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PD_SubmitDraftFree]
go

create procedure dbo.PD_SubmitDraftFree
(
	@RID int	
	,@PrivatePartyContact nvarchar(50)
	,@PrivatePartyEmail nvarchar(510)
	,@LargestCapacity int
	,@PrivatePartyPhone nvarchar(50)
	,@PrivatePartyShortDescription nvarchar(1000)
	,@PDChangeMask int	
	,@SubmittedBy nvarchar(500)
	,@LanguageId int
	,@PDPreviewLogID int
)
 
as  

/* 
	Private Dining : Stored procedure to insert data in PrivateDiningInfoDraft table.  
	Content owned by India team, please notify asaxena@opentable.com if changing.
	
	Deprecated
	
*/
	

go

GRANT EXECUTE ON [PD_SubmitDraftFree] TO ExecuteOnlyRole
go




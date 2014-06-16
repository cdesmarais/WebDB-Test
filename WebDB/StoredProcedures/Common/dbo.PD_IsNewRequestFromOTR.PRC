

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PD_IsNewRequestFromOTR]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PD_IsNewRequestFromOTR]
go

create procedure dbo.PD_IsNewRequestFromOTR
(
	@RID int
	,@IsPPDFromOTR bit	
	,@bIsNewRequest bit output
)
as  

	/* 
	This SP is used to find out IS New Request has been sumbitted for PD 
	Content owned by India team, please notify asaxena@opentable.com if changing.
	*/

	/* 
	New request flag status = yes in following cases
	For first free draft submitted via OTR  irrespective of whether data exists for PD on charm site
	For first premium draft submitted via OTR irrespective of whether data exists for PD on charm site
	For first premium draft submitted from OTR after premium listing is enabled in OTR. This flag status holds true even if free draft is already submitted through OTR
	*/
	
	declare @DraftCount int
	declare @LastPPDStatus bit
	declare @IsOTRFreePD bit
	set @IsOTRFreePD = 0
	set @DraftCount = 0
	set @bIsNewRequest = 0
	
	
	select 
		@DraftCount= COUNT(PDLogID) 
	from 
		PrivateDiningUpdateLog 
	where 
		RID = @RID 
		and SubmittedFromOTR =1 
		and IsSubmitted = 1 
		and ApprovedDTUTC is not null
	
	/* If there is no record exists means it is the new request*/	
	if (@DraftCount = 0)
	begin
		set @bIsNewRequest =1
		return
	end
	
	
	if (@IsPPDFromOTR = 1)
	begin
			/* Get the Last Approved PD Status. If Current PDStatus = Premium and Last PDStatus = Free then New Request = true*/
			select 
				Top 1 @IsOTRFreePD = IsPPD
			from 
				PrivateDiningUpdateLog 
			where 
				RID = @RID 
				and SubmittedFromOTR =1 
				and IsSubmitted = 1 
				and ApprovedDTUTC is not null
				order by PDLogID Desc
			
			if 	(@IsOTRFreePD = 0)
			begin
					set @bIsNewRequest =1
					return
			end
		
	end	
go

GRANT EXECUTE ON [PD_IsNewRequestFromOTR] TO ExecuteOnlyRole
go





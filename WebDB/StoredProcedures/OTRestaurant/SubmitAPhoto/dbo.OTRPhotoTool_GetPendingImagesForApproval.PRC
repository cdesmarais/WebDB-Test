

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTRPhotoTool_GetPendingImagesForApproval]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTRPhotoTool_GetPendingImagesForApproval]
go

create procedure [dbo].[OTRPhotoTool_GetPendingImagesForApproval]
as
begin
	/*
		This procedure returns list of pending requests from the OTRSubmittedImages table.
		Content owned by India team. Please notify asaxena@opentable.com, if changing.
	*/

	select 
		r.RID
		,r.RName
		,m.MetroAreaName
		,dbo.fConvertFromUTC(osi.SubmittedDTUTC,4)as SubmittedDTPST /* Get Modified date in PST format. */
		,osi.SubmittedBy	
	from
		OTRSubmittedImages osi
	inner join
		RestaurantVw r
		on osi.RID = r.RID
	inner join
		NeighborhoodVw n
		on r.NeighborhoodID = n.NeighborhoodID
	inner join
		MetroAreaVw m
		on n.MetroAreaID = m.MetroAreaID
	order by
		osi.SubmittedDTUTC asc

end

go

grant execute on [OTRPhotoTool_GetPendingImagesForApproval] to ExecuteOnlyRole

go


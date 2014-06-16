

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Restaurant_GetCutOffAndPartySizeInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Restaurant_GetCutOffAndPartySizeInfo]
go

create procedure dbo.Admin_Restaurant_GetCutOffAndPartySizeInfo
(
	@RID int
)
as
    select	 
        r.RID as Restaurant_ID
		,r.MinOnlineOptionID
		,r.MaxOnlineOptionID
        ,Case 
            When
                (
                    r.MaxLargePartyID > r.MaxOnlineOptionID
                ) 
            then 'Y' 
            else 'N' 
        end as CCRequired
		,ma.MaxAdvanceOption
        ,case 
            when 
            exists(
                    select 
                        ShiftTemplateID
                    from 
                        ShiftTemplate
                    where 
                        RID = r.[RID] 
                        and Active=1
                        and CutoffActive = 1
                  ) 
            then 'Yes' 
            else 'No'
         end as HasCutOffTime
    from		
        Restaurant r
        inner join  MaxAdvanceOption ma 
        on 
r.MaxAdvanceOptionID = ma.MaxAdvanceOptionID
    where		
        r.RID= @RID

go

grant execute on [Admin_Restaurant_GetCutOffAndPartySizeInfo] to ExecuteOnlyRole

go


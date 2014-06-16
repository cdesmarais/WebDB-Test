if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantCutOff]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantCutOff]
GO

CREATE PROCEDURE dbo.DNRestaurantCutOff
 As

SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @wk_yesterday datetime
declare @wk_tomorrow datetime
declare @weekday datetime
declare @res_date datetime

	select
        @weekday		= datepart(dw,getdate())
        ,@wk_tomorrow		= datepart(dw,getdate()+1)
        ,@wk_yesterday		= datepart(dw,getdate()-1)
        ,@res_date		= cast(convert(nvarchar, getdate(), 110) as datetime)


--*************************
--** Order by needed for Web Server index creation
--*************************
select * from
(
	select st.RID
		,@res_date searchDt
		,st.ResCutOffTime as cutoff_time
		,s.ShiftName 'SName'
,st.opentime 
,st.closetime 
		from		shifttemplate st
		inner join	scheduleshifts ss
		on		st.shifttemplateid = ss.shifttemplateid
		and		st.RID = ss.RID
		inner join	shift s
		on		ss.shiftid = s.shiftid
		where ss.scheduleid =	coalesce((select scheduleid from spcschassign
   						where spcschassign.RID = st.RID and
   						cast(convert(nvarchar, assignmentdate, 110) as datetime) = @res_date),@weekday)
		and		st.shiftid = ss.shiftid
		and		st.active = 1
		and		st.cutoffactive = 1
union
	select st.RID
		,@res_date+1 searchDt
		,st.ResCutOffTime as cutoff_time
		,s.ShiftName 'SName'
,st.opentime 
,st.closetime 
		from		shifttemplate st
		inner join	scheduleshifts ss
		on		st.shifttemplateid = ss.shifttemplateid
		and		st.RID = ss.RID
		inner join	shift s
		on		ss.shiftid = s.shiftid
		where ss.scheduleid =	coalesce((select scheduleid from spcschassign
   						where spcschassign.RID = st.RID and
   						cast(convert(nvarchar, assignmentdate, 110) as datetime) = @res_date+1),@wk_tomorrow)
		and		st.shiftid = ss.shiftid
		and		st.active = 1
		and		st.cutoffactive = 1
union
	select st.RID
		,@res_date-1 searchDt
		,st.ResCutOffTime as cutoff_time
		,s.ShiftName 'SName'
,st.opentime 
,st.closetime 
		from		shifttemplate st
		inner join	scheduleshifts ss
		on		st.shifttemplateid = ss.shifttemplateid
		and		st.RID = ss.RID
		inner join	shift s
		on		ss.shiftid = s.shiftid
		where ss.scheduleid =	coalesce((select scheduleid from spcschassign
   						where spcschassign.RID = st.RID and
   						cast(convert(nvarchar, assignmentdate, 110) as datetime) = @res_date-1),@wk_tomorrow)
		and		st.shiftid = ss.shiftid
		and		st.active = 1
		and		st.cutoffactive = 1		
) temp
order by rid, searchDT

go

GRANT EXECUTE ON [DNRestaurantCutOff] TO ExecuteOnlyRole

GO

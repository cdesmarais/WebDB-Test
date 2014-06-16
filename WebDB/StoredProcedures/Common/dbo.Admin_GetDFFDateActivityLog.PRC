

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetDFFDateActivityLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetDFFDateActivityLog]
GO

create procedure dbo.Admin_GetDFFDateActivityLog
(
	@MetroAreaID int
)
as 

/* This Proc is use to get DFF Date Activity History
Select current DFF Status from metroArea table and Histroy for DFF Status from the DFFDateActivityLog table  */

declare @TimeZoneID int
declare @DFFDisabled as varchar(25)
declare @DFFEnabled as varchar(25)
declare @TimeZoneCode as varchar(5)

set @TimeZoneCode = 'PST'
set @DFFDisabled = 'DFF Disabled'
set @DFFEnabled = 'DFF Enabled – Date : '

/* Need to display DFFChangeActionDTUTC in PST */
select 
	@TimeZoneID= TZID
from
	TimeZoneVW 
where 
	code =@TimeZoneCode

select 
	MetroAreaID
	,dbo.fConvertFromUTC(DFFChangeActionDTUTC,@TimeZoneID) as DFFChangeActionDTUTC
	,case 
		when(coalesce(convert(varchar(10),DFFStartDT,101),'') = '') then @DFFDisabled 
		else @DFFEnabled + convert(varchar(10),DFFStartDT,101)
	end as DFFStartDT

from 
	MetroArea

where 
	MetroAreaID = @MetroAreaID

union

(
	select 
		MetroAreaID
		,dbo.fConvertFromUTC(DFFChangeActionDTUTC,@TimeZoneID) as DFFChangeActionDTUTC
		,case 
			when(coalesce(convert(varchar(10),DFFStartDTPST,101),'') = '') then @DFFDisabled 
			else @DFFEnabled + convert(varchar(10),DFFStartDTPST,101)
		end as DFFStartDT

	from
		DFFDateActivityLog

	where 
		MetroAreaID = @MetroAreaID
)
order by 
	DFFChangeActionDTUTC desc	

GO

GRANT EXECUTE ON [Admin_GetDFFDateActivityLog] TO ExecuteOnlyRole

GO



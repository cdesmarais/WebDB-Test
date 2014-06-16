if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobUpdateDST]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobUpdateDST]
GO

CREATE PROCEDURE dbo.JobUpdateDST
	@CurDateUTC datetime = null
AS

set @CurDateUTC = IsNull(@CurDateUTC,getutcdate())


--******************************
--** update Timezone table set DSTActive (or not active) if it's in schedule (or not)
--** only modify records where a change is necessary
--******************************
update		TimeZone 
set			DSTActive = (case when d.DSTType is not null then 1 else 0 end),
			LastUpdateUTC = @CurDateUTC
from		Timezone tz
left join	DSTSchedule d
on			tz.DSTType = d.DSTType
and			DateAdd(mi, (convert(int, ScheduleIsLocal) * _offsetMI), @CurDateUTC)  between d.DSTStartDT and d.DSTEndDT
where		tz.DSTActive != (case when d.DSTType is not null then 1 else 0 end)
and			DateDiff(mi, LastUpdateUTC, @CurDateUTC) > 60 -- can not have changed in less than 60 minutes; prevents double set when DST ends
and			tz.SupportsDST = 1  -- This must be outside the left join (must be in where clause)



--****************************************************
--** Update the Job Schedule; Set the next run
--****************************************************
	declare @dbName nvarchar(1000)
	select @dbName = db_name(db_id())
	
	declare @JobName nvarchar(1000)
	
	if (@dbName = 'WebDB') begin
		set @JobName = 'UpdateDST'
	end	
	else if (@dbName = 'WebDB_ASIA') begin
		set @JobName = 'UpdateDST_ASIA'
	end
	else if (@dbName = 'WebDB_EU') begin
		set @JobName = 'UpdateDST_EU'
	end
	else begin
		set @JobName = 'UpdateDST'
	end

declare @JobID uniqueidentifier
select @JobID = job_id from msdb.dbo.sysjobs where name = @JobName
if (@JobID is not null)
begin
	declare @NextDT datetime

	select @NextDT = min(DSTDate)
	from (
		(select 		DSTDate = min(case 	when ScheduleIsLocal = 1 
								then	DateAdd(mi, LocalToServerOffsetMI, DSTEndDT)
								else	DateAdd(mi, ServerGMTOffsetMi, DSTEndDT) 
						end) 
		from		TimezoneVW tz
		inner join	DSTSchedule d
		on			tz.DSTType = d.DSTType
		-- If DST Schedule is in GMT leave time in UTC otherwise convert UTC to local
		and			DateAdd(mi, (convert(int, ScheduleIsLocal) * _offsetMI), @CurDateUTC) < d.DSTEndDT
		and			(case 	when ScheduleIsLocal = 1 
						then 	DateAdd(mi, LocalToServerOffsetMI, DSTEndDT) 
						else	DateAdd(mi, ServerGMTOffsetMi, DSTEndDT) 
					end) > DateAdd(mi, ServerOffsetMI, @CurDateUTC)
		
		where		tz.SupportsDST = 1
		) 
	union all
		
		(select 		DSTDate = min(case 	when ScheduleIsLocal = 1 
							then 	DateAdd(mi, LocalToServerOffsetMI, DSTStartDT) 
							else	DateAdd(mi, ServerGMTOffsetMi, DSTStartDT) 
						end)
		from		TimezoneVW tz
		inner join	DSTSchedule d
		on			tz.DSTType = d.DSTType
		-- If DST Schedule is in GMT leave time in UTC otherwise convert UTC to local
		and			DateAdd(mi, (convert(int, ScheduleIsLocal) * (_offsetMI)), @CurDateUTC)< d.DSTStartDT
		-- Confirm date is in the future
		and			(case 	when ScheduleIsLocal = 1 
						then 	DateAdd(mi, LocalToServerOffsetMI, DSTStartDT) 
						else	DateAdd(mi, ServerGMTOffsetMi, DSTStartDT) 
					end) > DateAdd(mi, ServerOffsetMI, @CurDateUTC) -- Confirm coverted local time is greater than current local time

		where		tz.SupportsDST = 1
		) 	
	) d

	select @NextDT [NextSchedDate] 
	
	if (@NextDT < getdate())
		set @NextDT = DateAdd(mi, 30, getdate())
	
	declare @jobDate int
	declare @jobTime int

	--** Put jobdate and jobtime in correct format		
	set @jobDate = datepart(yyyy, @NextDT)*10000+datepart(mm, @NextDT)*100+datepart(dd, @NextDT)
	set @jobTime = datepart(hh, @NextDT)*10000+datepart(mi, @NextDT)*100
	

	EXECUTE msdb.dbo.sp_update_jobschedule @job_id = @JobID, @name = N'NextRun', @enabled = 1, @freq_type = 1, @active_start_date = @jobDate, @active_start_time = @jobTime	
	
end



--****************************
--** Error Check Schedule
--****************************
if exists(
	select *
	from		TimezoneVW tz
	left join	DSTSchedule d
	on			tz.DSTType = d.DSTType
	-- If DST Schedule is in GMT leave time in UTC otherwise convert UTC to local
	and			DateAdd(mi, (convert(int, ScheduleIsLocal) * _offsetMI), @CurDateUTC) < d.DSTEndDT
	where		tz.SupportsDST = 1
	and			d.DSTType is null -- must be in where clause; null indicates no future schedule exists
)
Begin
	select		'No DST Schedule in DSTSchedule table for: '
				, *
	from		TimezoneVW tz
	left join	DSTSchedule d
	on			tz.DSTType = d.DSTType
	-- If DST Schedule is in GMT leave time in UTC otherwise convert UTC to local
	and			DateAdd(mi, (convert(int, ScheduleIsLocal) * _offsetMI), @CurDateUTC) < d.DSTEndDT
	where		tz.SupportsDST = 1
	and			d.DSTType is null -- must be in where clause; null indicates no future schedule exists

	RAISERROR ('Error DST Schedule not up to date.', 17,1)
End



GO
GRANT EXECUTE ON [JobUpdateDST] TO ExecuteOnlyRole

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procUpdateLTCMultiRID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procUpdateLTCMultiRID]
GO

CREATE Procedure dbo.procUpdateLTCMultiRID
 (
  @Restaurants varchar(8000) --[EV: List of Int IDs]
 )
As

SET NOCOUNT ON

Declare @DateNow as datetime, @UTCNow as datetime

Select @DateNow = GetDate(), @UTCNow = GetUTCDate() -- Add UTCNow to track LTC_UTC field

Declare @RIDCount int
set @RIDCount = 0

--**************************
--** Convrt RID List to  @RID Table
--**************************
declare @RIDTab table (Id int)
insert into @RIDTab (id) (select distinct id from  dbo.fIDStrToTab(@Restaurants, '|'))
set @RIDCount = @@RowCount

--**************************
--** Logging: Prep: Log is limited to 5000 chars total
--** if rid list is split into 2 4000 char sets if needed
--**************************
--Retrieve the hostname 
declare @HostName nvarchar(100)
select @HostName = hostname from master.dbo.sysprocesses
	where spid = @@SPID

-- All text is ASCI (NO NEED TO CONVERT TO NVARCHAR OR NTEXT)
declare @traceMessage varchar(5000)  
declare @traceMessage2 varchar(5000)
set @traceMessage = ' RID Count: ' + cast(@RIDCount as varchar(10))
	+ ' rid len: ' + cast(len(@Restaurants) as varchar(10)) 
	+ ' rids:' + substring(@Restaurants,1,4000)
if len(@Restaurants) > 4000
	set @traceMessage2 = substring(@Restaurants,4001,8000)
--**************************
--** Logging: PrepEnd
--**************************	


declare @lastCount int		
update	LastTimeContacted --with (UPDLOCK)
set		LTC = @DateNow,
		LTC_UTC = @UTCNow
where	rid in (select id from @RIDTab) 
and LTC_UTC < @UTCNow
set @lastCount = @@ROWCOUNT


--**************************
--** Logging: 
--**************************	

if (@@ERROR <> 0) 
begin
	--Record the failure
	set @traceMessage = 'LTC Update Failed: ' + @traceMessage
	exec DNErrorAdd 7100, 'procUpdateLTCMultiRID: TRACE', @traceMessage, 1
end
else if (@lastCount <> @RIDCount)
begin
	set @traceMessage = 'LTC Update Mismatch: actual: ' + cast(@lastCount as nvarchar(10)) + @traceMessage
	exec DNErrorAdd 7100, 'procUpdateLTCMultiRID: TRACE', @traceMessage, 2
end
	
--**************************
--** Logging: End
--**************************	

GO

GRANT EXECUTE ON [procUpdateLTCMultiRID] TO ExecuteOnlyRole

GO

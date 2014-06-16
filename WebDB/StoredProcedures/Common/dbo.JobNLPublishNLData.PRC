if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobNLPublishNLData]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobNLPublishNLData]
go

create procedure dbo.JobNLPublishNLData
as

set nocount on
set transaction isolation level read uncommitted

declare @genDate datetime

exec dbo.DNGetNLMapGenerationDateTime  @Date=@genDate OUTPUT

if (@genDate is null)
	return(0)

if (@genDate > getdate())
  return(0)

declare @ct int

select @ct = count(*) from [dbo].[NLData]
where [MapFilePublishedDt] is null and [LastModifiedDt] <= @genDate

if (@ct = 0)
  return(0)

declare db_cursor cursor for
select s.ServerID, ss.dynamicchecksumlive, ss.updatedt, ms.GeneratedDT
from serversite ss
inner join server s on s.serverid = ss.serverid
inner join sitetype st on st.sitetypeid = ss.sitetypeid
left join (select ServerID, siteTypeId, max(GeneratedDT) as GeneratedDT
			from mapFileStatus
			group by ServerID, SiteTypeID) ms on ss.serverid = ms.serverid
where ss.sitetypeid in (207,208,209) -- ISAPIWeb_NA, ISAPIWeb_EU and ISAPIWeb_Asia
and st.enabled = 1
and s.active = 1
and s.acceptstraffic = 1 

declare @serverid int
declare @dynamicchecksum  nvarchar(50)
declare @updateddt datetime
declare @initial_dynamicchecksum   nvarchar(50)
declare @generateddt datetime 

open db_cursor
fetch next from db_cursor  
into @serverid, @initial_dynamicchecksum, @updateddt, @generateddt

if (@@fetch_status <> 0)
	goto exit_handler;

set @dynamicchecksum = @initial_dynamicchecksum

while @@fetch_status =0
begin
	if (@generateddt is null)
		goto exit_handler;
	if (@genDate <> @generateddt)
		goto exit_handler;
	if (@dynamicchecksum <> @initial_dynamicchecksum)
		goto exit_handler;
	
	fetch next from db_cursor
	into @serverid, @dynamicchecksum, @updateddt, @generateddt
end


close db_cursor
deallocate db_cursor 

--update NLData  to publish new records
--set up transaction
set transaction isolation level SERIALIZABLE

begin transaction NLPublishNLData

update [dbo].[NLData]
	set [MapFilePublishedDt] = @genDate
where [MapFilePublishedDt] is null and [LastModifiedDt] <= @genDate

if (@@error = 0)
begin
	commit transaction NLPublishNLData
	return(0)
end else
begin
	rollback transaction NLPublishNLData
	return (1)
end

exit_handler: 
    close db_cursor
	deallocate db_cursor 
	return(1)
go


grant execute on [dbo].[JobNLPublishNLData] to ExecuteOnlyRole
go
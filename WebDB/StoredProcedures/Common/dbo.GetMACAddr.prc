
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetMACAddr]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetMACAddr]
GO

-- Called from ROMS to get MAC address
create procedure dbo.GetMACAddr
(
	@theRID int
)
as

set nocount on
set transaction isolation level read uncommitted

-- get restaurant rogue information..
declare @theIsRogueERB int
declare @theReportedNetworkAddress nvarchar(60)
declare @theRogueRetryMins int
declare @theCutoffTime datetime

set @theRogueRetryMins = 60 -- the log looks back 2 * retry mins to check if the erb is still a rogue..
set @theReportedNetworkAddress = 'Not Reported'
set @theCutoffTime = dateadd(mi,(2 * -1 * @theRogueRetryMins),getdate())

	-- check if rogue ..
		select 
			@theIsRogueERB=count(*) 
		from 
			AuthNetworkAddressLog 
		where
			RID=@theRID 
			AND AuthSuccess=0
			AND LogDate >= @theCutoffTime 
			
	-- get last reported MAC address of rogue..
	if @theIsRogueERB > 0
	begin
		select 
			top 1 @theReportedNetworkAddress=ReportedNetworkAddress  
		from AuthNetworkAddressLog 
		where
			RID=@theRID 
			AND AuthSuccess=0
			AND LogDate >= @theCutoffTime 
		order by 
			LogDate desc
end		
	
	select 
		coalesce(NetworkAddress,'Not Reported') as NetworkAddress,
		@theIsRogueERB as IsRogueERB,		
		coalesce(@theReportedNetworkAddress,'Not Reported') as ReportedNetworkAddress		
	from
		ErbRestaurant e
	inner join
		RestaurantVW rvw
	on
		rvw.RID = e.RID
	where 
		e.rid=@theRID


GO

GRANT EXECUTE ON [GetMACAddr] TO ExecuteOnlyRole

GO

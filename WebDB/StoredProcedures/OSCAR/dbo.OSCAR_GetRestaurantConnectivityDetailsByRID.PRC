
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OSCAR_GetRestaurantConnectivityDetailsByRID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[OSCAR_GetRestaurantConnectivityDetailsByRID]
go
  
create procedure [dbo].OSCAR_GetRestaurantConnectivityDetailsByRID  
(  
	@RID int	
)  
as      
      
/**********************************************************************************        

 OSCARA API uses this proc to get restaurant connectivity details from consumer database for synchronization into Salesforce.
 Content owned by India team, please notify asaxena@opentable.com if changing.        
************************************************************************************/      
begin    

		-- get restaurant rogue information..
		declare @theIsRogueERB int
		declare @theReportedNetworkAddress nvarchar(60)
		declare @theRogueRetryMins int
		declare @theCutoffTime datetime 

		set @theRogueRetryMins = 60 -- the log looks back 2 * retry mins to check if the erb is still a rogue..
		set @theReportedNetworkAddress = 'Not Reported'
		set @theCutoffTime = dateadd(mi,(2 * -1 * @theRogueRetryMins),getdate())
		set @theIsRogueERB = 0

		-- check if rogue ..
		select 
			@theIsRogueERB=count(*) 
		from 
			AuthNetworkAddressLog 
		where
			RID=@RID 
			and AuthSuccess=0
			and LogDate >= @theCutoffTime 
			
		-- get last reported MAC address of rogue..
		if @theIsRogueERB > 0
		begin
			select 
				top 1 @theReportedNetworkAddress=ReportedNetworkAddress  
			from 
				AuthNetworkAddressLog 
			where
				RID=@RID 
				and AuthSuccess=0
				and LogDate >= @theCutoffTime 
			order by 
				LogDate desc
		end 
		
		select      
			er.RID
			,er.ServerIP        
			,coalesce(LTC.LTC, r.CreateDate) as LastTimeContactedDTPST     
			,case 
				when r.RestStateID = 1 AND isReachable = 1 then   
				'Reserve Now'        
				when r.RestStateID = 1 AND isReachable = 0 then   
				'Back Soon'        
				else 
				rs.RState			      
			end as RStatus
			,coalesce(er.NetworkAddress, null) as MACAddress
			,er.ERBVersion
			,@theIsRogueERB as RogueERB
			,@theReportedNetworkAddress as ReportedMACAddress
 		from   
			ERBRestaurant er        
			
			inner join Restaurant r on   
			er.rid = r.rid        

			inner join RestaurantState rs  on       
			r.RestStateID = rs.RestStateID        

			left outer join LastTimeContacted LTC on         
			er.rid = LTC.rid        
			
			left outer join CCAccountStatusTypes ccTypes
			on r.CCAccountStatusID = ccTypes.CCAccountStatusID
			
		where   
			r.RID = @RID

end    

go

grant execute on [OSCAR_GetRestaurantConnectivityDetailsByRID] to ExecuteOnlyRole


go

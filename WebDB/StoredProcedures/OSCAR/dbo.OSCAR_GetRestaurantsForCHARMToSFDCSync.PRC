	
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OSCAR_GetRestaurantsForCHARMToSFDCSync]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OSCAR_GetRestaurantsForCHARMToSFDCSync]
go


create procedure [dbo].[OSCAR_GetRestaurantsForCHARMToSFDCSync]
(
	@HighWaterMarkChangeRowVersion rowversion  = 0x00000000
)
as

/*
	Get the Delta updated Restaurant record along with their Private Dining and POP information.
	Only those records will be return which are modified after last successfully synch record.
*/

    set transaction ISOLATION LEVEL read UNCOMMITTED
	
	declare @MaxChangeRowVersion rowversion
	declare @RogueRetryMins int  
	declare @CutoffTime datetime
	  
	--Creating Temp Table to hold RID whose PrivateDining or POP information is updated
	create table #UpdatedRID 
	(
		 RID int		 
		,ChangeRowVersion varbinary(16)
	)
	
	--Temporary table to store report network/mac addresses
	create table #ReportedNetworkAddress 
	(
		 RID int
		 ,ReportedNetworkAddress varchar(60)
	)
	
	create table #PrivateDiningUpdateLog
	(
		RID int
		,UpdateLogDTUTC datetime
	)
	
	create table #PrivateDiningUpdateLogForPublished
	(
		RID int
		,UpdateLogDTUTC datetime
	)
	
	set @RogueRetryMins = 60 -- the log looks back 2 * retry mins to check if the erb is still a rogue..  
	set @CutoffTime = dateadd(mi,(2 * -1 * @RogueRetryMins), getdate()) 
	
	--Getting max updatelogDTUTC for a RID, when private dining was unpublished
	insert into #PrivateDiningUpdateLog
	select  
	    PrivateDiningUpdateLog.rid
		,convert(varchar(10),max(UpdateLogDTUTC),101)  as UpdateLogDTUTC
	from 
		PrivateDiningUpdateLog     
	where
		UpdatedValues like '%Published%False%Published%'
	group by 
		PrivateDiningUpdateLog.rid
				        
	
	-- Getting Max updatelogDTUTC for a RID, when private dining was published
	insert into #PrivateDiningUpdateLogForPublished
	select 
		RID, 
		MAX(UpdateLogDTUTC) 'UpdateLogDTUTC'
	from 
		PrivateDiningUpdateLog 
	where 
		UpdatedValues like '%Published%True%Published%'
	group by 
		RID
	
	
	--Getting those RID for which Private Dining Information is updated after HWM
	insert into #UpdatedRID 
	select 
		  pdul.RID
		 ,max(pdul.ChangeRowVersion)
	from
		PrivateDiningUpdateLog pdul
	where		
		pdul.ChangeRowVersion > @HighWaterMarkChangeRowVersion
		and ( UpdatedValues like '%Published%True%Published%' or UpdatedValues like '%Published%False%Published%' )
	group by
		pdul.RID
		
	
	
	-- Merge the RID whose Private Dining Information is updated with RID whose POP information is updated.
	merge #UpdatedRID as target
    using 
		(
			select 
				 inc.RID
				,max(dbo.fGetMaxRowVersion(inc.IncChangeRowVersion,inc.IncRestStatusChangeRowVersion))
			from	
				IncentiveVW inc
			where
				dbo.fGetMaxRowVersion(inc.IncChangeRowVersion,inc.IncRestStatusChangeRowVersion) > @HighWaterMarkChangeRowVersion
				and inc.LastMinutePopThresholdTime is null
			group by 
				RID
		) as source (RID, ChangeRowVersion)
     on (target.RID = source.RID)
     when matched then 
        UPDATE set ChangeRowVersion = dbo.fGetMaxRowVersion(source.ChangeRowVersion,target.ChangeRowVersion)
	 when not matched by target then	
	    insert
			 (RID, ChangeRowVersion)
	    values
			 (source.RID, source.ChangeRowVersion);
	
	-- Merge the RID if RName,Braintree Account Status,Facebook URL,Restaurant Menu URL,
	-- Has Profile Image is updated
	merge #UpdatedRID as target
	using
		(
			select 
				r.RID
				,dbo.fGetMaxRowVersion(r.ChangeRowVersion,RImage.ChangeRowVersion)
			from  
				Restaurant r 
				left outer join RestaurantImage RImage
				on r.RID = RImage.RID
			where 
				(r.ChangeRowVersion > @HighWaterMarkChangeRowVersion
				or RImage.ChangeRowVersion > @HighWaterMarkChangeRowVersion)
		) as source (RID, ChangeRowVersion)
	on (target.RID = source.RID)
	when matched then
		update set ChangeRowVersion = dbo.fGetMaxRowVersion(source.ChangeRowVersion, target.ChangeRowVersion)
	when not matched by target then
		insert
			(RID, ChangeRowVersion)
		values
			(source.RID, source.ChangeRowVersion);
	

	-- Merge the RID if record in ERBRestaurant is updated
	merge #UpdatedRID as target
	using 
		(
			select 
				er.RID
				,er.ERBRestChangeRowVersion
			from  
				ERBRestaurant er
			where 
				(er.ERBRestChangeRowVersion > @HighWaterMarkChangeRowVersion)
		) as source (RID, ChangeRowVersion)
	on (target.RID = source.RID)
	when matched then
		update set ChangeRowVersion = source.ChangeRowVersion
	when not matched by target then
		insert
			(RID, ChangeRowVersion)
		values
			(source.RID, source.ChangeRowVersion);
			
	--Keeping only Top 1000 RID order by ChangeRowVersion
	-- We need to delete remaining records because we are going to return only 1000 records
	-- So we have to find MAX change row version out of those 1000 records. 
	-- Elimanting remaining records will improve performace of join.
	delete from 
		#UpdatedRID 
	where
		RID not in ( 
						select 
							Top 500 RID 
						from 
							#UpdatedRID 
						order by 
							ChangeRowVersion asc
					 )
			 
	 --Getting MAX Change Row Version 
	 select 
		@MaxChangeRowVersion = max(ChangeRowVersion)
	 from 
		#UpdatedRID
	
	--Get top 1 reported network/mac address for each restaurant where LogDate >= CutoffTime 
	;with ReportedNetworkAddressCTE(RID, LogID)
	as
	(
		select
			RID
			,MAX(LogID)   
		from
			AuthNetworkAddressLog   
		where  
			AuthSuccess = 0 and  
			LogDate >= @CutoffTime
		group by
			RID 
	)
	insert into #ReportedNetworkAddress
			(
				RID
				,ReportedNetworkAddress
			)
	select
			ANAL.RID
			,ReportedNetworkAddress
	from
		#UpdatedRID U
		inner join ReportedNetworkAddressCTE RNACTE on
			U.RID = RNACTE.RID
		inner join AuthNetworkAddressLog ANAL on
			RNACTE.RID = ANAL.RID and RNACTE.LogID = ANAL.LogID
	
			
	select 
		     rest.RID  
			,rest.PublishPrivateDining  
			,CONVERT(VARCHAR(10),MAX(pdul.UpdateLogDTUTC),101) AS PublishedDTUTC  
			,case    
				rest.PublishPrivateDining    
				when 0 then    
					(
						SELECT  
							convert(varchar(10),max(UpdateLogDTUTC),101)
						FROM 
							#PrivateDiningUpdateLog     
						WHERE
							 rest.rid = #PrivateDiningUpdateLog.rid     
						and	 rest.PublishPrivateDining = 0    
					)    
				else    
					null    
				end as UnpublishedDTUTC     
			,IsNull(inc.active, 0)   as 'POPParticipant'  
		   ,case   
				when inc.active = 1 then   
					sum(dbo.fCalculatePrimeTimePOPSlotsCount(inc.StartTime , inc.EndTime, 'L')) + sum(dbo.fCalculatePrimeTimePOPSlotsCount(inc.StartTime , inc.EndTime, 'D'))  
				else   
					0  
			end 'TotalPrimeTimeSlots'  
			,rest.RName 
			,ccTypes.CCAccountStatus 
			,rest.FacebookURL
			,rest.MenuURL 
			,coalesce([ImageName],0) 'HasProfileImage'
			,@MaxChangeRowVersion 'ChangeRowVersion'
			,case 
				when rest.RestStateID = 1 AND rest.IsReachable = 1 then   
				'Reserve Now'        
				when rest.RestStateID = 1 AND rest.IsReachable = 0 then   
				'Back Soon'        
				else 
				rs.RState			      
			end as RStatus
			,coalesce(LTC.LTC, rest.CreateDate) as LastTimeContactedDTPST
			,er.ServerIP
			,er.NetworkAddress as MACAddress
			,er.ERBVersion
			,ISNULL(RNA.RID, 0) as RogueERB	--send RID if record found in temp table or zero
			,RNA.ReportedNetworkAddress as ReportedMACAddress
			,tz._offsetHR as TZOffset
			,rest.Latitude
			,rest.Longitude
	from   
			#UpdatedRID updated
			 
			inner join RestaurantVW rest
			on Updated.RID = rest.RID 
	
			left outer join #PrivateDiningUpdateLogForPublished pdul
			on pdul.rid = rest.RID	
			
			left outer join IncentiveVW inc
			on inc.RId = rest.RID
			and inc.Active =1
			and inc.LastMinutePopThresholdTime is null
			
			left outer join CCAccountStatusTypes ccTypes
			on rest.CCAccountStatusID = ccTypes.CCAccountStatusID
			
			left outer join RestaurantImage RImage
			on rest.RID = RImage.RID
			
			inner join RestaurantState rs  on       
			rest.RestStateID = rs.RestStateID
			
			left outer join LastTimeContacted LTC on         
			rest.RID = LTC.RID
			
			left outer join ERBRestaurant er on
			rest.RID = er.RID
			
			left outer join #ReportedNetworkAddress RNA on
			rest.RID = RNA.RID
			
			left outer join TimeZone tz
			on rest.TZID = tz.TZID
	group by
		   rest.RID  
		  ,rest.PublishPrivateDining  
		  ,inc.Active
		  ,RName
		  ,ccTypes.CCAccountStatus
		  ,rest.FacebookURL
		  ,rest.MenuURL
		  ,ImageName
		  ,rest.RestStateID
		  ,rest.IsReachable
		  ,rs.RState
		  ,coalesce(LTC.LTC, rest.CreateDate)
		  ,er.ServerIP
		  ,er.NetworkAddress
		  ,er.ERBVersion
		  ,RNA.RID
		  ,RNA.ReportedNetworkAddress
		  ,tz._offsetHR
		  ,rest.Latitude
		  ,rest.Longitude

go

grant execute on [OSCAR_GetRestaurantsForCHARMToSFDCSync] to ExecuteOnlyRole

go



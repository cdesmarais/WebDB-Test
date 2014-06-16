


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Report_ERBConnect]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Report_ERBConnect]

GO

create Procedure dbo.Report_ERBConnect 
as 
set transaction isolation level read uncommitted
set nocount on

declare @CurrentDate datetime
set @CurrentDate = getdate()

-- Flush working set table. Records that need to be sent faxes are finally stored in ERBConnect.
-- At the start of each run, flush ERBConnect and populate again based on the current situation
-- If a restaurant is currently in state "active" and has contacted the website within 12 hours
-- its deemed to be online
delete  
from   
	 ERBConnect  
where   
	RID in
			(  
				select   
					r.RID  
				from   
					Restaurant r  

	    			inner join LastTimeContacted ltc on  
					r.RID = ltc.RID  
				where   
					r.RestStateID = 1 and  
					datediff(minute, ltc.LTC, @CurrentDate) < 720  
			)  
option (KEEPFIXED plan)  

  
  
--insert any NEW Restaurants that have lost connectivity. This is based on LTC being more than 12 hours
insert into ERBConnect  
(  
	RID  
)  
select   
	r.RID  
from   
	Restaurant r  
   
	inner join LastTimeContacted ltc on  
	r.RID = ltc.RID  
   
	inner join Neighborhood n on  
	r.NeighborhoodID = n.NeighborhoodID  

where   
	r.RestStateID = 1 and   
	r.country not in ('JP') and -- do not include JP restaurants  
	datediff(minute, ltc.LTC, @CurrentDate) >= 720 and   
	n.MetroAreaID <> 1 and   
	r.allotment <> 1 and
   (coalesce(r.IsOptOutForFRNandBackSoon ,0) <> 1 or coalesce(r.IsOptOutEmailForFRNandBackSoon ,0) <> 1) and
	r.RID not in
				(  
					select   
						RID  
					from   
						ERBConnect  
				)  
option (KEEPFIXED plan)  
  
--insert any NEW Restaurants which is in FRN state for more than 12 consecutive hours  
insert into ERBConnect
(
	RID
)  
 
select   
	r.RID   
from  
	Restaurant r  

	inner join Neighborhood n on  
	r.NeighborhoodID = n.NeighborhoodID  

where   
	r.RestStateID = 16 and  
	r.country not in ('JP') and  
	n.MetroAreaID <> 1 and  
	r.allotment <> 1 and  
	(coalesce(r.IsOptOutForFRNandBackSoon ,0) <> 1 or coalesce(r.IsOptOutEmailForFRNandBackSoon ,0) <> 1) and
	r.RID not in  
	(  
		select  
			RID  
		from  
			ERBConnect  
	) and
	-- This function retuns 1 if rest satisfies FRN condition else return 0
	dbo.fIsRestInFRNstateForADuration(r.RID,@CurrentDate) = 1
option (KEEPFIXED plan)  
  
    
-- Insert new restarunt which was flapping in last 72 hours and it's offline time is more than 50% of the time means 36 hours  
insert into ERBConnect  
(  
	RID  
)  
select   
	r.RID   
from  
	Restaurant r  

	inner join Neighborhood n on  
	r.NeighborhoodID = n.NeighborhoodID  

where  
	r.country not in ('JP') and   
	n.MetroAreaID <> 1 and   
	r.allotment <> 1 and  
	(coalesce(r.IsOptOutForFRNandBackSoon ,0) <> 1 or coalesce(r.IsOptOutEmailForFRNandBackSoon ,0) <> 1) and
	r.RID not in(  
					select   
						RID  
					from  
						ERBConnect  
				)and
	-- If this function retuns 1 means RID in in FRN or BackSoon, or combination of both in more than 36 hrs.
	dbo.fIsRestFlappingInADuration(r.RID,@CurrentDate ) = 1
option (KEEPFIXED plan)  


  
--select the restaurant information for notification  
select   
	ec.RID as restaurant_id  
	,r.RName as Name  
	,er.ServerIP as server_ip  
	,ltc.LTC as last_time_contacted  
	,@CurrentDate as report_date  
	-- First access ROMS fax# if it is not there then try to get from CHARM
	-- Remove trailing and leading spaces
	,case when (len(restcontinfo.RestFaxNumber) = 0 or restcontinfo.RestFaxNumber is null)  then 
		ltrim(rtrim(r.FaxPhone)) COLLATE SQL_Latin1_General_CP1_CI_AS 
	else
		ltrim(rtrim(restcontinfo.RestFaxNumber))COLLATE SQL_Latin1_General_CP1_CI_AS 
	end as fax_Phone 
	, NotifyDate  
	,case when r.HasNoFax = 0 and r.country in ('US','CA') then 
	--Restaurant has FaxTelephone number
		r.IsOptOutForFRNandBackSoon
	else
	--If fax number is not provided then ignore r.IsOptOutForFRNandBackSoon so providing 1 
	--(1 Do not send fax notification)
	  1
	end as IsOptOutFaxNotification
	,r.IsOptOutEmailForFRNandBackSoon as IsOptOutEmailNotification --Opt out for Email Notification or not
	,restcontinfo.PrimContactFirstname +' '+restcontinfo.PrimContactLastname as PrimaryContactName -- Contact Name from ROMS
	,restcontinfo.PrimContactemail as  SendToEmailAddress		
	,r.PrimaryLanguageID
	
from  
	ERBConnect ec  

	inner join RestaurantVW r on  
	r.RID = ec.RID  
   
	inner join ErbRestaurant er on  
	r.RID = er.RID  
  
	inner join LastTimeContacted ltc on  
	r.RID = ltc.RID  

	left join ROMSRestaurantContactInfo restcontinfo
	on	r.RID = restcontinfo.WebID 
  
where  
	-- send only for 5 consecutive days. Stop after that.
	datediff(dd,coalesce(NotifyDate,@CurrentDate),@CurrentDate) < 5 and  
	r.country not in ('JP') -- do not include JP restaurants 
order by   
	r.RName  
option (KEEPFIXED plan)  

-- mark "sent" date.   
update   
	ERBConnect  
set   
	NotifyDate = @CurrentDate  
where   
	NotifyDate is null  

option (KEEPFIXED plan)  


GO


grant execute on [Report_ERBConnect] to ExecuteOnlyRole


GO


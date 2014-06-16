if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SvcResoMigration_GetRestaurantMigrationResos]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SvcResoMigration_GetRestaurantMigrationResos]
GO

CREATE Procedure dbo.SvcResoMigration_GetRestaurantMigrationResos
(
    @RestaurantMigrationQueueID   int
)
As
SET NOCOUNT ON
set transaction isolation level read uncommitted

declare @DTNow datetime
declare @NumUnqueuedResos int
declare @SourceRID int
declare @DestinationRID int
declare @RestaurantMigrationTypeID int
declare @ExclusionQueueID int
declare @ExclusionTaskStatus varchar
declare @PrevMigrationTypeID int
declare @NumPrevMigratedResos int
select @DTNow = GETDATE()

if (not exists (select RestaurantMigrationQueueID from RestaurantMigrationQueue where RestaurantMigrationQueueID = @RestaurantMigrationQueueID))
begin
    -- if this happens, we will fail the XML RestaurantMigration task
    raiserror('The specified migration task (%d) does not exist', 16, 1, @RestaurantMigrationQueueID)
end


begin tran

-- get the SourceRID, DestinationRID and MigrationType of the migration from RestaurantMigrationQueueID
SELECT  @SourceRID = SourceRID,
	@DestinationRID = DestinationRID,
        @RestaurantMigrationTypeID = RestaurantMigrationTypeID
        
FROM RestaurantMigrationQueue
WHERE RestaurantMigrationQueueID = @RestaurantMigrationQueueID

-- get the QueueID from which to exclude reservations if migrating in the same direction
-- (going from same SourceRID to same DestinationRID with the same RestaurantMigrationTypeID - indicates same direction)
SELECT top 1 @ExclusionQueueID    = RestaurantMigrationQueueID
            ,@ExclusionTaskStatus = TaskStatus
            ,@PrevMigrationTypeID = RestaurantMigrationTypeID
            
from        RestaurantMigrationQueue
WHERE         SourceRID = @SourceRID
and DestinationRID = @DestinationRID
-- exclude current task whose status will be 'P' - In progress
and TaskStatus = 'CS' or TaskStatus = 'CE'
-- very important (ensures that most recent migration prior to the current migration is picked by select top 1)
ORDER BY DueDT DESC

if (@PrevMigrationTypeID is not null)
-- there has been prior migration from the same source rid to destination rid
begin
	if (@PrevMigrationTypeID = @RestaurantMigrationTypeID)
	-- the prior migration has been in the same direction
	begin 
	    -- Delete any resos from RestaurantMigrationReso that are a part of RestaurantMigratedReso (last migration)
	    -- regardless of whether the last task was success (CS) or failure (CE)
	    -- CE check is just for extra security (RestaurantMigratedReso will not contain any ResID in RestaurantMigrationReso if Status is CE)	

		delete RestaurantMigrationReso 
		from RestaurantMigrationReso mnReso 
		inner join RestaurantMigratedReso mdReso
		on mnReso.ResID = mdReso.ResID
		WHERE mdReso.RestaurantMigrationQueueID = @ExclusionQueueID
		
		select @NumPrevMigratedResos = @@ROWCOUNT
		if (@NumPrevMigratedResos > 0)
		begin
		   update  RestaurantMigrationQueue
  		   set     NumResos = NumResos - @NumPrevMigratedResos
   		   where   RestaurantMigrationQueueID = @RestaurantMigrationQueueID
		end
	end
end

-- "True-up" step:
-- Delete RestaurantMigrationReso entries whose resos moved into the past.
delete      RestaurantMigrationReso 
from        RestaurantMigrationReso         m

inner join  Reservation                     reso
on          reso.ResID                      = m.ResID

inner join  Restaurant                      rest
on          rest.RID                        = reso.RID

inner join  TimezoneVW                      tzv
on          tzv.TZID                        = rest.TZID

where       reso.ShiftDate between @DTNow - 30 and ShiftDate + 2      -- General Partition key technique to quickly narrow set to any thing  30 days past and 2 days forward
and         (
            -- reso is in past or is no longer pending
              (reso.ShiftDate + reso.ResTime + 2) <= tzv.currentLocalTime -- specific time check to identifty resos in the past
or            RStateID != 1
)

-- If rowcount > 0 then update total resos in Master Task
select @NumUnqueuedResos = @@ROWCOUNT
if (@NumUnqueuedResos > 0)
begin
    update  RestaurantMigrationQueue
    set     NumResos = NumResos - @NumUnqueuedResos
    where   RestaurantMigrationQueueID = @RestaurantMigrationQueueID
end

commit tran

select  r.ResID                                             ResID      
       ,r.PartySize                                         PartySize  
       ,r.ShiftDate                                         ShiftDate  
       ,r.ResTime                                           ResTime    
       ,r.Notes                                             Notes      
       ,r.ErbNotes                                          ErbNotes  
       ,r.CustID                                            CustID
       ,coalesce(c.LName, cc.LName)                         CustLName
       ,coalesce(c.FName, cc.FName)                         CustFName
       ,coalesce(c.SLName, cc.SLName)                       CustSLName
       ,coalesce(c.SFName, cc.SFName)                       CustSFName
       ,coalesce(c.Email, cc.Email)                         CustEmail
       ,case
            when rcecu.CustID is not null then convert(bit,1)
            when rceca.CallerID is not null then convert(bit,1)
            else convert(bit,0)
        end                                                 CustSendAnnouncements
       ,coalesce(min(
                     -- Special Case: Convert Work Phone to Home
                     case 
                         when cp.PhoneTypeID = 2 then 1 
                         else cp.PhoneTypeID 
                     end
                    )
                 , 1)                                       CustPhoneTypeID
       ,coalesce(min(cp.PhoneCountryID), cc.PhoneCountryID) CustPhoneCountryID
       ,r.ContactPhone                                      CustPhone
       ,coalesce(r.CallerID, 0)                             CallerID
       ,case
          when ca.PositionID = 2 then convert(bit, 1)
          else convert(bit, 0)
        end                                                 IsConcierge                                                
       ,ca.LName                                            CallerLName
       ,ca.FName                                            CallerFName
       ,ca.SFname                                           CallerSFName
       ,ca.SLname                                           CallerSLName
       ,coalesce(min(cap.PhoneTypeID), 1)                   CallerPhoneTypeID
       ,min(cap.PhoneCountryID)                             CallerPhoneCountryID
       ,min(cap.Phone)                                      CallerPhone
       ,co.CompanyName                                      Company
       ,co.Phone                                            CompanyPhone
       ,ro.OfferID
       ,ov.VersionID
       ,restoff.OfferClassID
       ,CASE 
			WHEN	ov.OfferName IS NOT NULL AND  restoff.OfferClassID = 4 THEN ov.OfferName
			ELSE 
					ov.OfferDescription
		END  AS OfferDescription
       ,rr.RedemptionID
       ,rr.RedemptionDescription
       ,rr.RedemptionCover
       ,coalesce(gpcust._GlobalPersonID, gpcallcust._GlobalPersonID)		CustPersonID
       ,gpcall._GlobalPersonID												CallerPersonID
          
from        RestaurantMigrationReso         m

inner join  RestaurantMigrationQueue        q
on          q.RestaurantMigrationQueueID    = m.RestaurantMigrationQueueID

inner join  Reservation                     r
on          r.ResID                         = m.ResID

left join   Customer                        c
on          c.CustID                        = r.CustID
and         r.CallerID                      is null

left join   CallerCustomer                  cc
on          cc.CustID                       = r.CustID   
and         r.CallerID                      is not null

left join   Caller                          ca
on          ca.CallerID                     = r.CallerID

left join   Company                         co
on          co.CompanyID                    = ca.CompanyID

LEFT JOIN   RestaurantCustomerEmail         rcecu 
on          rcecu.CustID                    = r.CustID 
AND         rcecu.RID                       = r.RID

LEFT JOIN   RestaurantCustomerEmail         rceca
on          rceca.CallerID                  = r.CallerID
AND         rceca.RID                       = r.RID

-- 1-to-many, because Customer may have entered the same phone number multiple times 
-- under different phone types (home, mobile, work)
left join   CustomerPhone                   cp
on          cp.CustID                       = r.CustID
and         r.CallerID                      is null
and         cp.Phone                        = r.ContactPhone

-- 1-to-many because uniqueness constraint on (CallerID, IsPrimary) is not enforced
left join   CallerPhone                     cap
on          cap.CallerID                    = r.CallerID
and         cap.IsPrimary                   = 1

-- TT 54015 pick up any Offers data associated with the reso
LEFT JOIN	ReservationOffer ro WITH (NOLOCK)
ON			r.ResID = ro.ResID

LEFT JOIN	OfferVersion ov WITH (NOLOCK)
ON			ro.OfferID = ov.OfferID
AND			ro.VersionID = ov.VersionID

LEFT JOIN	RestaurantOffer restoff WITH (NOLOCK)
ON		    ro.OfferID = restoff.RestaurantOfferID

LEFT JOIN	ReservationRedemption rr WITH (NOLOCK)
ON			r.ResID = rr.ResID

LEFT JOIN	GlobalPerson gpcust WITH (NOLOCK)
ON			gpcust.CustID = r.CustID

LEFT JOIN	GlobalPerson gpcall WITH (NOLOCK)
ON			gpcall.CallerID = r.CallerID

LEFT JOIN	GlobalPerson gpcallcust
ON			gpcallcust.CustID = r.CustID
AND			r.CallerID			IS NOT NULL

where       r.ShiftDate > @DTNow - 2        -- General Partition key technique to quickly narrow set to any thing  greater than 2 days ago
and         m.RestaurantMigrationQueueID    = @RestaurantMigrationQueueID
and         q.TaskStatus                    = 'P'   -- defensive programming; restrict to in-progress tasks


group by     r.ResID      
            ,r.PartySize  
            ,r.ShiftDate  
            ,r.ResTime    
            ,r.Notes      
            ,r.ErbNotes   
            ,r.CustID     
            ,c.LName 
            ,cc.LName 
            ,c.FName 
            ,cc.FName 
            ,c.SLName
            ,cc.SLName
            ,c.SFName
            ,cc.SFName
            ,c.Email 
            ,cc.Email 
            ,c.SendAnnouncements
            ,cp.Phone                       
            ,cc.PhoneCountryID        
            ,r.ContactPhone 
            ,r.CallerID                     
            ,ca.PositionID   
            ,ca.LName           
            ,ca.FName           
            ,ca.SFname          
            ,ca.SLname          
            ,co.CompanyName     
            ,co.Phone    
            ,rcecu.CustID 
            ,rceca.CallerID      
		    ,ro.OfferID
		    ,ov.VersionID
		    ,restoff.OfferClassID
		    ,CASE 
				WHEN	ov.OfferName IS NOT NULL AND  restoff.OfferClassID = 4 THEN ov.OfferName
				ELSE 
						ov.OfferDescription
			 END 
		    ,rr.RedemptionID
		    ,rr.RedemptionDescription
		    ,rr.RedemptionCover
		    ,gpcust._GlobalPersonID
		    ,gpcall._GlobalPersonID
		    ,gpcallcust._GlobalPersonID
GO

GRANT EXECUTE ON [SvcResoMigration_GetRestaurantMigrationResos] TO ExecuteOnlyRole

GO

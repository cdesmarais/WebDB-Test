if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SvcResoMigration_Setup_ERB_GC]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SvcResoMigration_Setup_ERB_GC]
GO

CREATE Procedure dbo.SvcResoMigration_Setup_ERB_GC

As
SET NOCOUNT ON
set transaction isolation level read uncommitted


declare     @DTNow datetime
declare     @DTRestaurantNow datetime
declare     @NumResos table
(   
            RestaurantMigrationQueueID int not null,
            NumResos int not null
)

--=============================================================================
-- generate the recordset for .NET: 
-- the set of Ready or InProgress past-due tasks
--=============================================================================
select      @DTNow = GETDATE()

--=============================================================================
-- Quickly determine if any work to be done and retrieve working set. 
-- If no work exit
--=============================================================================
select       RestaurantMigrationQueueID
            ,ForceFit
            ,DestinationRID
			,RestaurantMigrationTypeID
			,TaskStatus
from        RestaurantMigrationQueue 
where       TaskStatus                  = 'R'
and         DueDT                       <= @DTNow

-- no ready tasks, no work to do, return early
if (@@ROWCOUNT = 0) 
    return 0

begin tran

--=============================================================================
-- enqueue pending future reservations
-- CONNECT->GC MIGRATIONS ONLY
-- for ready, past-due, new tasks (R(0)=>P(0))
--=============================================================================
insert      RestaurantMigrationReso
(            
             ResID
            ,RestaurantMigrationQueueID
)
select       reso.ResID
            ,q.RestaurantMigrationQueueID
from        RestaurantMigrationQueue    q

inner join  Reservation                 reso
on          reso.RID                    = q.SourceRID

inner join  Restaurant                  rest
on          rest.RID                    = q.SourceRID                

inner join  TimezoneVW                  tzv
on          tzv.TZID                    = rest.TZID

-- where the master task is ready, past due, and has not yet been attempted
where       q.TaskStatus                = 'R'
and			q.RestaurantMigrationTypeID = 3			--for  Connect only
and         q.DueDT                     <= @DTNow
and         q.NumAttempts               = 0


--=============================================================================
-- enqueue guests
-- CONNECT->GC MIGRATIONS ONLY
--=============================================================================

insert RestaurantMigrationGuest
(
			CustID
			,RestaurantMigrationQueueID
)
(
select	distinct c.CustID
				,r.RestaurantMigrationQueueID
from			RestaurantMigrationReso		r
inner join		Reservation                 reso
on				reso.ResID					= r.ResID

inner join		Customer					c
on				c.CustID                   = reso.CustID

inner join		RestaurantMigrationQueue	q
on				q.RestaurantMigrationQueueID = r.RestaurantMigrationQueueID

where			q.TaskStatus                = 'R'
and				q.RestaurantMigrationTypeID = 3			--for  Connect only
and				q.DueDT                     <= @DTNow
and				q.NumAttempts               = 0
)
union

(select	distinct cc.CustID
				,r.RestaurantMigrationQueueID
from			RestaurantMigrationReso		r
inner join		Reservation                 reso
on				reso.ResID					= r.ResID

inner join		CallerCustomer				cc
on				cc.CustID					= reso.CustID

inner join		Caller						cl
on				cl.CallerID                 = reso.CallerID



inner join		RestaurantMigrationQueue	q
on				q.RestaurantMigrationQueueID = r.RestaurantMigrationQueueID

where			q.TaskStatus                = 'R'
and				q.RestaurantMigrationTypeID = 3			--for  Connect only
and				q.DueDT                     <= @DTNow
and				q.NumAttempts               = 0
)

--=============================================================================
-- update the NumResos count
-- for ready, past-due, new tasks (R(0)=>P(0))
-- CONNECT->GC MIGRATIONS ONLY
--=============================================================================
insert      @NumResos
select      q.RestaurantMigrationQueueID
            ,count(*) as NumResos
from        RestaurantMigrationQueue        q

inner join  RestaurantMigrationReso         r
on          r.RestaurantMigrationQueueID    = q.RestaurantMigrationQueueID

where       q.TaskStatus                    = 'R'
and			q.RestaurantMigrationTypeID		= 3			--for  Connect only
and         q.DueDT                         <= @DTNow
and         q.NumAttempts                   = 0

group by    q.RestaurantMigrationQueueID

--=============================================================================
-- enqueue pending future reservations
-- for ready, past-due, new tasks (R(0)=>P(0))
-- NON-CONNECT->GC AND NON-ERB->GC MIGRATIONS
--=============================================================================
insert      RestaurantMigrationReso
(            
             ResID
            ,RestaurantMigrationQueueID
)
select       reso.ResID
            ,q.RestaurantMigrationQueueID
from        RestaurantMigrationQueue    q

inner join  Reservation                 reso
on          reso.RID                    = q.SourceRID

inner join  Restaurant                  rest
on          rest.RID                    = q.SourceRID                

inner join  TimezoneVW                  tzv
on          tzv.TZID                    = rest.TZID

-- where the master task is ready, past due, and has not yet been attempted
where       q.TaskStatus                = 'R'
and         q.DueDT                     <= @DTNow
and         q.NumAttempts               = 0
and			q.RestaurantMigrationTypeID != 2			--for  NON-ERB->GC 
and			q.RestaurantMigrationTypeID != 3			--for  NON-Connect->GC 

-- and the reso occurs in the future, and is pending
and         reso.ShiftDate > @DTNow - 2      -- General Partition key technique to quickly narrow set to any thing greater than 2 days ago
and         (reso.ShiftDate + reso.ResTime + 2) > tzv.currentLocalTime -- specific time check to identifty resos in the future
and         reso.RStateID                  = 1


--=============================================================================
-- update the NumResos count
-- for ready, past-due, new tasks (R(0)=>P(0))
-- NON-CONNECT->GC MIGRATIONS
--=============================================================================
insert      @NumResos
select      q.RestaurantMigrationQueueID
            ,count(*) as NumResos
from        RestaurantMigrationQueue        q

inner join  RestaurantMigrationReso         r
on          r.RestaurantMigrationQueueID    = q.RestaurantMigrationQueueID

where       q.TaskStatus                    = 'R'
and         q.DueDT                         <= @DTNow
and         q.NumAttempts                   = 0
and			q.RestaurantMigrationTypeID != 2			--for  NON-ERB->GC 
and			q.RestaurantMigrationTypeID != 3			--for  NON-Connect->GC 

group by    q.RestaurantMigrationQueueID

update      RestaurantMigrationQueue   
set         NumResos                        = t.NumResos
from        RestaurantMigrationQueue        q

inner join  @NumResos                       t
on          t.RestaurantMigrationQueueID    = q.RestaurantMigrationQueueID

--====================================
-- update the TaskStatus 
-- and the LastAttemptDT
-- for Ready/InProgress tasks
--====================================
update      RestaurantMigrationQueue 
set          TaskStatus                  = 'P'
            ,LastAttemptDT              = @DTNow
where       TaskStatus                  = 'R'
and         DueDT                       <= @DTNow


commit tran
GO

GRANT EXECUTE ON [SvcResoMigration_Setup_ERB_GC] TO ExecuteOnlyRole

GO
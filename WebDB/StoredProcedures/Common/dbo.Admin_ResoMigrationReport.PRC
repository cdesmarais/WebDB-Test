if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ResoMigrationReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ResoMigrationReport]
GO


CREATE Procedure dbo.Admin_ResoMigrationReport
 (
    @SourceRID int,
  @DestinationRID int
 )
As
SET NOCOUNT ON

-- This proc uses the default isolation level: readcommitted. 
-- We only want to read committed data from the SvcResoMigration_Setup transaction.

declare @RestaurantMigrationQueueID int
declare @TaskStatus varchar(2)
declare @RestaurantMigrationLastAttemptDT datetime
declare @DueDT datetime
declare @CreatedDT datetime
declare @NumAttempts int
declare @ResoTotalCount int
declare @ResoQueueCount int
declare @ResoSuccessCount int
declare @ResoFailureCount int
declare @ResoPendingCount int
declare @RestaurantMigrationTypeID int
declare @MigrateToGC bit
declare @GuestTotalCount int

declare @RestaurantMigrationReso table
(
     ResID int not null
    ,ErrorCode int null
    ,LastAttemptDT datetime null
    ,ErrorMessage [nvarchar](500) null
    ,IsPending bit not null
)

declare @RestaurantMigrationGuest table
(
     CustID int not null
)

-- pull master task
-- if there are multiple instances, select the most recent
select       Top 1
             @RestaurantMigrationQueueID        = RestaurantMigrationQueueID
            ,@TaskStatus                        = TaskStatus
            ,@DueDT                             = DueDT
            ,@CreatedDT 			= CreatedDT
            ,@RestaurantMigrationLastAttemptDT  = LastAttemptDT
            ,@NumAttempts                       = NumAttempts
            ,@ResoTotalCount                    = coalesce(NumResos,0)
            ,@RestaurantMigrationTypeID			= RestaurantMigrationTypeID
from        RestaurantMigrationQueue 
where       SourceRID                           = @SourceRID
and         DestinationRID                      = @DestinationRID
order by    RestaurantMigrationQueueID          desc

set @GuestTotalCount = 0

if (@RestaurantMigrationTypeID = 2 or @RestaurantMigrationTypeID = 3)
begin
	set @MigrateToGC = 1	
	insert      @RestaurantMigrationReso
	(
				 ResID 
				,IsPending -- semantics: pending retry
	)
	select       ResID
				,1
	from        RestaurantMigratedReso
	where       RestaurantMigrationQueueID = @RestaurantMigrationQueueID
	
	select @ResoQueueCount = @@ROWCOUNT
	select @ResoSuccessCount = @ResoQueueCount
	
	insert      @RestaurantMigrationGuest
	(
				 CustID 
	)
	select       CustID
	from        RestaurantMigratedGuest
	where       RestaurantMigrationQueueID = @RestaurantMigrationQueueID
		
	select @GuestTotalCount = @@ROWCOUNT
end
else
begin
	set @MigrateToGC = 0
	-- pull detail tasks, and classify as completed with errors, or pending retry
	insert      @RestaurantMigrationReso
	(
				 ResID 
				,ErrorCode
				,LastAttemptDT 
				,ErrorMessage 
				,IsPending -- semantics: pending retry
	)
	select       ResID
				,ErrorCode
				,LastAttemptDT
				,ErrorMessage
				,case 
					-- if master task has been requeued and not yet launched, all detail tasks are considered pending 
					when (@TaskStatus = 'R' and @NumAttempts > 0) then 1
					-- if master task in progress, all detail tasks not yet attempted are considered pending 
					when (@TaskStatus = 'P' and coalesce(LastAttemptDT, 0) < @RestaurantMigrationLastAttemptDT)  then 1
					-- otherwise detail task has been tried, and has errors 
					else 0
				 end
	from        RestaurantMigrationReso
	where       RestaurantMigrationQueueID = @RestaurantMigrationQueueID

	select @ResoQueueCount = @@ROWCOUNT
	select @ResoSuccessCount = @ResoTotalCount - @ResoQueueCount
end
select @ResoFailureCount = COUNT(*) from @RestaurantMigrationReso where IsPending = 0
select @ResoPendingCount = @ResoQueueCount - @ResoFailureCount

-- report on master task status
-- this will return an empty recordset if there is no master task
select       @SourceRID                         as SourceRID
    ,@DestinationRID                    as DestinationRID
    ,@DueDT as DueDT
    ,@CreatedDT as CreatedDT
    ,@RestaurantMigrationTypeID			as RestaurantMigrationTypeID
    ,case @TaskStatus
        when 'R'    then 'Ready'
        when 'P'    then 'In Progress'
        when 'CE'   then 'Completed with Errors'
        when 'CS'   then 'Completed Successfully'
        else             'Unknown'
     end                                as TaskStatus
    ,@RestaurantMigrationLastAttemptDT  as LastAttemptDT
    ,@NumAttempts                       as NumAttempts
    ,@ResoSuccessCount                  as NumResosSuccess
    ,@ResoFailureCount                  as NumResosFailed
    ,@ResoPendingCount                  as NumResosPending
    ,@GuestTotalCount					as GuestTotalCount
from        RestaurantMigrationQueue 
where       RestaurantMigrationQueueID          = @RestaurantMigrationQueueID

if (@MigrateToGC = 1)
begin
		-- report on detail task status
	-- this will return an empty recordset if there is no master task
	select       ResID                    
	from        @RestaurantMigrationReso   
	
	select       CustID                    
	from        @RestaurantMigrationGuest  
end
else
	-- report on detail task status
	-- this will return an empty recordset if there is no master task
	select       m.ResID                    as ResID
				,r.ShiftDate                as ShiftDate
				,r.ResTime                  as ResTime
				,coalesce(c.FName, cc.FName)    as PartyFName
				,coalesce(c.LName, cc.LName)    as PartyLName
				,r.PartySize                as PartySize
				,m.ErrorCode                as ErrorCode
				,case m.IsPending
					when 1      then m.ErrorMessage + ' (Pending Retry)'
					else        m.ErrorMessage
				 end                        as ErrorMessage
				,m.LastAttemptDT            as LastAttemptDT
	            
	from        @RestaurantMigrationReso    m
	inner join  Reservation                 r
	on          r.ResID                     = m.ResID  

	left join   Customer                        c
	on          c.CustID                        = r.CustID
	and         r.CallerID                      is null

	left join   CallerCustomer                  cc
	on          cc.CustID                       = r.CustID   
	and         r.CallerID                      is not null

GO

GRANT EXECUTE ON [Admin_ResoMigrationReport] TO ExecuteOnlyRole

GO

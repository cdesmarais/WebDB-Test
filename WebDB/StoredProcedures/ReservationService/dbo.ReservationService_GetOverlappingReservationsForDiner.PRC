if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ReservationService_GetOverlappingReservationsForDiner]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ReservationService_GetOverlappingReservationsForDiner]
GO

create procedure dbo.ReservationService_GetOverlappingReservationsForDiner
(
	@DinerID int,
	@ReservationDateTime datetime,
	@MinimumReservationSpacingInMinutes int,
	@ResIDForChange int = null
)
as
set nocount on
set transaction isolation level read uncommitted

-- time boundaries
DECLARE @MinExcludedDateTime datetime 
	= dateadd(mi, -1 * @MinimumReservationSpacingInMinutes, @ReservationDateTime)
DECLARE @MaxExcludedDateTime datetime 
	= dateadd(mi, @MinimumReservationSpacingInMinutes, @ReservationDateTime)

-- for reso partition selection
DECLARE @MinShiftDate datetime = cast(@MinExcludedDateTime as date)
DECLARE @MaxShiftDate datetime = cast(@MaxExcludedDateTime as date)

-- search
SELECT

-- get rid & confnum to build GET reservation url in make response
RID, ConfNumber
FROM Reservation

-- DinerID may be either a Customer or a CallerCustomer ID
where CustID = @DinerID

-- for change, ignore overlap with the reso we are about to change
and ((@ResIDForChange IS NULL) OR (@ResIDForChange != ResID))

-- narrow search to appropriate reservation table partition
AND ShiftDate between @MinShiftDate AND @MaxShiftDate

-- proper date arithmetic for midnight wraparound 
-- requires evaluating full datetime inequalities
and ShiftDate + cast(cast(ResTime AS TIME) AS DATETIME) 
	BETWEEN @MinExcludedDateTime AND @MaxExcludedDateTime

-- we only consider pending resos as overlapping
AND RStateID = 1 

go

grant execute on [ReservationService_GetOverlappingReservationsForDiner] to ExecuteOnlyRole

GO
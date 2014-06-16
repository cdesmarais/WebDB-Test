if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNReservationGetOriginal]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNReservationGetOriginal]
GO

CREATE Procedure dbo.DNReservationGetOriginal
 (
   @RID         int,
   @CustID      int,
   @CallerID	int,
   @ResDateTime datetime,
   @PartySize   int
 )
As
--************************************
--** This proc is used in the rare instances when a make transaction fails,
--** due to a duplicate reso (preexisting reso) having already been made or in the process of being made,
--** most likely due to an application error.
--**
--** This proc's goal is to retrieve the successfully made (committed) reso that matches the reso uniquness criteria.
--************************************
SET NOCOUNT ON

-- temp vars
declare @ShiftDate datetime
select @ShiftDate = CONVERT(nvarchar,@ResDateTime,102)

declare @ResTime datetime
select @ResTime = '12/30/1899 ' + CONVERT(nvarchar,@ResDateTime,108)

declare @DTNow datetime
select @DTNow = GETDATE()

-- the maximum age that the original reso request is allowed
-- to be returned by this proc
declare @MaxOriginalAgeSeconds int
select @MaxOriginalAgeSeconds = 60

declare @RowCount int
declare @ResID	int
declare @ConfNumber int

SELECT	 @ResID				= ResID
		,@ConfNumber		= ConfNumber

		-- This operation requires the reservation to have been succesfully made (committed)
FROM	Reservation (READCOMMITTED)
		
where	ShiftDate			= @ShiftDate				
and		RID					= @RID
and		IsNull(CallerID, 0) = IsNull(@CallerID, 0)						-- original was made by same caller, if any
and		CustID				= @CustID 
and		ResTime				= @ResTime
and		PartySize			= @PartySize
and		RStateID			= 1											-- original is pending
and		DATEDIFF(second, DateMade, @DTNow) < @MaxOriginalAgeSeconds		-- original was made within the last 60 seconds


select	@RowCount = @@ROWCOUNT
if (@RowCount = 1)
begin
	-- success: we found the duplicate
	SELECT		 @ResID          AS ResID
				,@ConfNumber     AS ConfNumber
	return
end

-- failure handling
declare @sShiftDate nvarchar(20)
select @sShiftDate = CONVERT(nvarchar(20), @ShiftDate, 102)
declare @sResTime nvarchar(20)
select @sResTime = CONVERT(nvarchar(20), @ResTime, 108)

if (@RowCount = 0)
begin
    raiserror('Duplicate reservation check returned empty recordset: RID=%d;CustID=%d;CallerID=%d;ShiftDate=%s;ResTime=%s;PartySize=%d', 16, 1,
               @RID, @CustID, @CallerID, @sShiftDate, @sResTime, @PartySize) 
    return
end

if (@RowCount > 1)
begin
    raiserror('Duplicate reservation check returned multiple original reservations: RID=%d;CustID=%d;CallerID=%d;ShiftDate=%s;ResTime=%s;PartySize=%d', 16, 1,
               @RID, @CustID, @CallerID, @sShiftDate, @sResTime, @PartySize) 
    return
end


GO

GRANT EXECUTE ON [DNReservationGetOriginal] TO ExecuteOnlyRole

GO


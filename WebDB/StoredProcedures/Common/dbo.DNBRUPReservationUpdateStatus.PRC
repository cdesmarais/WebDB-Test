if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNBRUPReservationUpdateStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNBRUPReservationUpdateStatus]
GO

CREATE PROCEDURE dbo.DNBRUPReservationUpdateStatus
(
	@RID		int,
	@ConfNumber	int,
	@ResStateID	int,
	@ValidStates varchar(100),
	@InvalidStates varchar(100)

)
as
SET NOCOUNT ON

set @ValidStates = IsNull(@ValidStates, '')
set @InvalidStates = IsNull(@InvalidStates, '')

--***********************************
--** This proc is called by BRUP and used to:
--** Mark Resos:
--**    No-Show
--**    Cancel ERB
--** Returns the number of rows affected
--** if it returns 0 then reso state has not changed
--**
--** Will not allow change to be made if reso is already in a valid state (white list) allowed transitions
--** Will not allow change to occur if reso state is in an invalid state (black list) Illigal transtions
--** Per the BizRule resos older than 30 are not allowed to be updated
--** Also ShiftDate needs to be added to the where clause to improve performance of the Partitioned Reservation Table
--** Setting row count=1 to improve the performance of Partitioned table
--***********************************
set rowcount 1
update	Reservation
set		RStateID = @ResStateID
where	RID        = @RID
and		ConfNumber = @ConfNumber
and		(@ValidStates = '' or RStateID in (select id from dbo.fIDStrToTab(@ValidStates, ',')) )
and		(@InvalidStates = '' or RStateID not in (select id from dbo.fIDStrToTab(@InvalidStates, ',')) )
and		RStateID != @ResStateID
and		ShiftDate >= dateadd(d,-30, getdate())

-- Return the Rowcount as a scalar value	
select @@rowcount as RowsAffected

set rowcount 0

GO

GRANT EXECUTE ON [DNBRUPReservationUpdateStatus] TO ExecuteOnlyRole

GO


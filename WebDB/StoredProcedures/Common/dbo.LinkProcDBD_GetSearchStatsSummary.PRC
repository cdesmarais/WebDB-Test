
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LinkProcDBD_GetSearchStatsSummary]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[LinkProcDBD_GetSearchStatsSummary]
GO



CREATE PROCEDURE [dbo].[LinkProcDBD_GetSearchStatsSummary]
@Resos	int	OUTPUT,
@Covers int	OUTPUT

As

/*
This proc gets called by the proc named "DBD_UpdateSearchStatsSummary" in WebLogDB which in turn is called by
the SQL Job named "Update Dashboard Stats"
*/

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Declare @curDT datetime
Declare @startDT datetime

set @curDT = getdate()
set @startDT = dateadd(mi, -5, @curDT)


Select	@Resos = Count(ResiD), 
		@Covers = coalesce(sum(coalesce(PartySize,0)),0)
from	dbo.reservation 
where	
		-- Trick to Quickly issolate data to appropriate partition; 
		-- Impossible for a Reso to have a datemade that is smaller than the shiftdate; 
		-- there are some cases when an ERB change trickles in late but there is a 30 day limit on these
		-- However it is possible for a reso to have a ShiftDate much greater than datemade (reso can be made far into the future)
		ShiftDate >= dateadd(dd, -30, @startDT)

and		DateMade >= @startDT
and		rstateid = 1


--The following error logging code is to capture the zero reso count Error scenario
IF ISNULL(@Resos,0)=0
 BEGIN
	DECLARE @ErrMsg	nvarchar(1000)

	SET @ErrMsg = 'Zero Reso Count Returned. [@curDT=' + CONVERT(NVARCHAR(50),@curDT,121) + '] [@startDT=' + CONVERT(NVARCHAR(50),@startDT,121) 
			+ '] [@Resos=' + ISNULL(CAST(@Resos AS NVARCHAR(50)), 'NULL') + '] [@@Error=' + CAST(@@ERROR AS NVARCHAR(50)) + ']'

 	EXEC [dbo].[DNErrorAdd] 1, 'DBD_UpdateSearchStatsSummary', @ErrMsg, 10
 END


GO


GRANT  EXECUTE  ON [dbo].[LinkProcDBD_GetSearchStatsSummary]  TO [ExecuteOnlyRole]
GO



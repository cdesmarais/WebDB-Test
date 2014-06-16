if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTConGetResosByRidDateStatus_V4]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTConGetResosByRidDateStatus_V4]
GO


CREATE PROCEDURE dbo.OTConGetResosByRidDateStatus_V4
(
	@RID				INT,
	@StartDate			DATETIME,
	@EndDate			DATETIME,
	@ShiftData			OTCShiftDataSetV2 READONLY,
	@StatusIDList		NVARCHAR(128)  -- comma-delimited list of ResoStatusIDs to include
)

AS

-- call the wrapped proc
EXEC procGetReservationsByRidDateRange_V4 @RID, @StartDate, @EndDate, @ShiftData, @StatusIDList

GO

GRANT EXECUTE ON OTConGetResosByRidDateStatus_V4 TO ConsoleExecuteRole

GO

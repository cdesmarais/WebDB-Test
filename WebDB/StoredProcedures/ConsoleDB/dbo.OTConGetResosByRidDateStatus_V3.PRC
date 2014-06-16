if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTConGetResosByRidDateStatus_V3]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTConGetResosByRidDateStatus_V3]
GO


CREATE PROCEDURE dbo.OTConGetResosByRidDateStatus_V3
(
	@RID				INT,
	@StartDate			DATETIME,
	@EndDate			DATETIME,
	@ShiftData			OTCShiftDataSetV2 READONLY,
	@StatusIDList		NVARCHAR(128)  -- comma-delimited list of ResoStatusIDs to include
)

AS

-- call the wrapped proc
EXEC procGetReservationsByRidDateRange_V3 @RID, @StartDate, @EndDate, @ShiftData, @StatusIDList

GO

GRANT EXECUTE ON OTConGetResosByRidDateStatus_V3 TO ConsoleExecuteRole

GO

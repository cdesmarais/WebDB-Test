if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTConGetResosByRidDateStatus_V2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTConGetResosByRidDateStatus_V2]
GO


CREATE PROCEDURE dbo.OTConGetResosByRidDateStatus_V2
(
	@RID				INT,
	@StartDate			DATETIME,
	@EndDate			DATETIME,
	@ShiftData			OTCShiftDataSet READONLY,
	@StatusIDList		NVARCHAR(128)  -- comma-delimited list of ResoStatusIDs to include
)

AS

-- call the wrapped proc
EXEC procGetReservationsByRidDateRange_V2 @RID, @StartDate, @EndDate, @ShiftData, @StatusIDList

GO

GRANT EXECUTE ON OTConGetResosByRidDateStatus_V2 TO ConsoleExecuteRole

GO

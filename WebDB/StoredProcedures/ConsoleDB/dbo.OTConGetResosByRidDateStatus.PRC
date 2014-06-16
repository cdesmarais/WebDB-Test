if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTConGetResosByRidDateStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTConGetResosByRidDateStatus]
GO


CREATE PROCEDURE dbo.OTConGetResosByRidDateStatus
(
	@RID				INT,
	@StartDate			DATETIME,
	@EndDate			DATETIME,
	@ShiftData			ShiftDataSetwID READONLY,
	@StatusIDList		NVARCHAR(128)  -- comma-delimited list of ResoStatusIDs to include
)

AS

-- call the wrapped proc
EXEC procGetReservationsByRidDateRange @RID, @StartDate, @EndDate, @ShiftData, @StatusIDList

GO

GRANT EXECUTE ON OTConGetResosByRidDateStatus TO ConsoleExecuteRole

GO

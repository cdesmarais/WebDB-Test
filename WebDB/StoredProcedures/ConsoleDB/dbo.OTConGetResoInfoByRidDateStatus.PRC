if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTConGetResoInfoByRidDateStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTConGetResoInfoByRidDateStatus]
GO


CREATE PROCEDURE dbo.OTConGetResoInfoByRidDateStatus
(
	@RID				INT,
	@StartDate			DATETIME,
	@EndDate			DATETIME,
	@StatusIDList		NVARCHAR(128)  -- comma-delimited list of ResoStatusIDs to include
)

AS

-- this version creates dummy shift data
DECLARE @DummyShiftData OTCShiftDataSet

-- call the wrapped proc
EXEC procGetReservationsByRidDateRange_V2 @RID, @StartDate, @EndDate, @DummyShiftData, @StatusIDList

GO

GRANT EXECUTE ON OTConGetResoInfoByRidDateStatus TO ConsoleExecuteRole

GO

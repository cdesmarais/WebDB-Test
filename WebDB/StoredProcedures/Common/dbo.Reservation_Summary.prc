if exists(select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_Summary]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_Summary]
go

CREATE PROCEDURE [dbo].[Reservation_Summary]
(
    @StartDate DATETIME,
    @EndDate DATETIME,
    @RStateIDList VARCHAR(1000),
    @IncludeConcierge BIT
)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @PartitionDate DATETIME
SET @PartitionDate = DATEADD(month, -1, @StartDate)

IF OBJECT_ID('tempdb..#Reservation') IS NOT NULL
  DROP TABLE #Reservation

CREATE TABLE #Reservation
(
  ResID INT NOT NULL,
  RID INT NOT NULL,
  RStateID INT NOT NULL,
  CompanyID INT NULL,
  IncentiveID INT NULL
)

INSERT INTO #Reservation
SELECT ResID, RID, RStateID, CompanyID, IncentiveID FROM Reservation
WHERE ShiftDate > @PartitionDate AND
      DateMade >= @StartDate AND
      DateMade < @EndDate + 1

IF (@IncludeConcierge=0)
  DELETE #Reservation
  WHERE CompanyID IS NOT NULL

SELECT RID,
       COUNT(ResID) AS TotalReservationCount,
       SUM(CASE WHEN IncentiveID IS NULL THEN 0 ELSE 1 END) AS POPReservationCount
FROM #Reservation
WHERE CHARINDEX(',' + CAST(RStateID AS VARCHAR) + ',', 
                ',' + @RStateIDList + ',')>0
GROUP BY RID

IF OBJECT_ID('tempdb..#Reservation') IS NOT NULL
  DROP TABLE #Reservation

GO



GRANT  EXECUTE  ON [Reservation_Summary]  TO [ExecuteOnlyRole]


Go




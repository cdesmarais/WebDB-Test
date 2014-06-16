if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Reservation_ReportDetails]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Reservation_ReportDetails]
GO

CREATE Procedure dbo.Concierge_Reservation_ReportDetails
 (
  @RestaurantID nvarchar(500),
  @FromDate datetime,
  @ToDate datetime,
  @ResoState nvarchar(1),
  @UserID int,
  @CompanyID int
 )
 
As

set transaction isolation level read uncommitted

if @RestaurantID = '0' SELECT @RestaurantID = ''if @ResoState = '0' SELECT @ResoState = ''if @UserID > 0
    SELECT CallerCustomer.FName as First_Name,CallerCustomer.LName as Last_Name,r.RName as RestaurantName,Reservation.RID AS RestaurantID,
         ResTime as Reservation_Time,Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End as Party_Size,ShiftDate as Shift_Date
    FROM Reservation 
    INNER JOIN RestaurantVW r 
    ON Reservation.RID = r.RID
    INNER JOIN CallerCustomer 
    ON Reservation.CustID=CallerCustomer.CustID
    WHERE  Reservation.CallerID = @UserID 
    AND (LEN(@RestaurantID) = 0 
    OR CHARINDEX(',' + CAST(Reservation.RID AS nvarchar(500))  + ',',',' + @RestaurantID + ',') > 0) 
    AND (LEN(@ResoState) = 0 
    OR CHARINDEX(',' + CAST(Reservation.RStateID AS nvarchar(1)) + ',',',' + @ResoState + ',') > 0)
    AND DateMade BETWEEN @FromDate AND @ToDate
    ORDER BY  ShiftDate ASC
if @UserID = 0
    SELECT CallerCustomer.FName as First_Name,CallerCustomer.LName as Last_Name,r.RName as RestaurantName,Reservation.RID AS RestaurantID,
         ResTime as Reservation_Time,Case when(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End as Party_Size,ShiftDate as Shift_Date
    FROM
         Reservation 
    INNER JOIN RestaurantVW r 
    ON			Reservation.RID = r.RID
    INNER JOIN	CallerCustomer 
    ON			Reservation.CustID=CallerCustomer.CustID
    WHERE
         Reservation.CompanyID=@CompanyID And
         (LEN(@RestaurantID) = 0 OR
         CHARINDEX(',' + CAST(Reservation.RID AS nvarchar(500))
            + ',',',' + @RestaurantID + ',') > 0) AND
         (LEN(@ResoState) = 0 OR
         CHARINDEX(',' + CAST(Reservation.RStateID AS nvarchar(1))
            + ',',',' + @ResoState + ',') > 0)
         AND DateMade BETWEEN @FromDate  AND @ToDate
    ORDER BY  ShiftDate ASC
    
GO

GRANT EXECUTE ON [Concierge_Reservation_ReportDetails] TO ExecuteOnlyRole

GO

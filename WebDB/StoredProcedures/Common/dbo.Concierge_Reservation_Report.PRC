if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Reservation_Report]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Reservation_Report]
GO

CREATE Procedure dbo.Concierge_Reservation_Report
 (
  @RestaurantID nvarchar(500),
  @FromDate datetime,
  @ToDate datetime,
  @UserID int,
  @CompanyID int
 )
 
As

set transaction isolation level read uncommitted

if @RestaurantID = '0' SELECT @RestaurantID = ''if @UserID > 0
    SELECT Count(*) As Reservations,
    Sum(Case
    When (Reservation.RStateID In(3)) Then 1 Else 0 End) As Cancellations,
    Sum(Case 
    When(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End) as Covers,
    Sum(Case
    When (Reservation.RStateID In(4)) Then 1 Else 0 End) As NoShows,
    r.RName as RestaurantName,Reservation.RID AS RestaurantID
    FROM
         Reservation 
    INNER JOIN 
		RestaurantVW r 
	ON	Reservation.RID = r.RID
    WHERE
         CallerID = @UserID AND
         (LEN(@RestaurantID) = 0 OR
            CHARINDEX(',' + CAST(Reservation.RID AS nvarchar(500))
                + ',',',' + @RestaurantID + ',') > 0)
         AND DateMade BETWEEN @FromDate  AND @ToDate
    GROUP BY Reservation.RID,r.RName
    ORDER BY r.RName,Reservation.RID
if @UserID = 0
    SELECT Count(*) As Reservations,
    Sum(Case
    When (Reservation.RStateID In(3)) Then 1 Else 0 End) As Cancellations,
    Sum(Case 
    When(Coalesce(seatedSize,0) < 1) Then Partysize Else seatedSize End) as Covers,
    Sum(Case
    When (Reservation.RStateID In(4)) Then 1 Else 0 End) As NoShows,
    r.RName as RestaurantName,Reservation.RID AS RestaurantID
    FROM
         Reservation 
    INNER JOIN 
		RestaurantVW r 
	ON  Reservation.RID = r.RID
    WHERE
         Reservation.CompanyID = @CompanyID And
         (LEN(@RestaurantID) = 0 OR
            CHARINDEX(',' + CAST(Reservation.RID AS nvarchar(500))
                + ',',',' + @RestaurantID + ',') > 0)
         AND DateMade BETWEEN @FromDate  AND @ToDate
    GROUP BY Reservation.RID,r.RName
    ORDER BY r.RName,Reservation.RID
    
GO

GRANT EXECUTE ON [Concierge_Reservation_Report] TO ExecuteOnlyRole

GO

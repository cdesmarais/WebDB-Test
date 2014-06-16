if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Reservation_LocalNoShow]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Reservation_LocalNoShow]
GO





CREATE PROCEDURE dbo.Concierge_Reservation_LocalNoShow
As
  SELECT metroareaid As Metro,
    COUNT(Reservation.Resid) AS Reservations,
    SUM(Case
    when (Reservation.RStateID = 4) then 1 Else 0 End) AS NoShows
    FROM Reservation 
	inner join Company On Reservation.CompanyID = Company.CompanyID
	where 	MetroareaID is not null
--Where datediff(mm,shiftDate,current_Timestamp) = 0-- and MetroareaID is not null
     Group By metroareaid
GO

GRANT EXECUTE ON [Concierge_Reservation_LocalNoShow] TO ExecuteOnlyRole

GO

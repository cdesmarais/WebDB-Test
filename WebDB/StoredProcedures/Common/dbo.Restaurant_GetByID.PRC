if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_GetByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_GetByID]
GO

CREATE Procedure dbo.Restaurant_GetByID
 (
  @RestaurantID int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT	r.RName AS RestaurantName
		,r.Address1 AS Address
		,r.City
		,r.State
		,r.Zip AS Zip
		,rm.RMDesc as Description
		,r.ExternalURL AS URL
		,rs.RState AS RestaurantState
		,'(' + Left(r.ReservationPhone,3) + ') ' + Left(Right(r.ReservationPhone,7),3) + '-' + Right(r.ReservationPhone,4) AS Phone
		,r.AcceptCheque As Cheque
		,n.metroareaid as Metro_Area_ID

FROM		RestaurantVW r
INNER JOIN	RestaurantState rs
ON			r.RestStateID = rs.RestStateID
INNER JOIN	RestaurantMessageAVW rm  
ON			rm.RID = r.RID
and			rm.LanguageID = r.LanguageID
INNER JOIN	NeighborhoodAVW n 
ON			n.neighborhoodid = r.neighborhoodid
and			n.LanguageID = r.LanguageID
WHERE		(r.RID = @RestaurantID)
ORDER BY	r.RName

GO

GRANT EXECUTE ON [Restaurant_GetByID] TO ExecuteOnlyRole

GO

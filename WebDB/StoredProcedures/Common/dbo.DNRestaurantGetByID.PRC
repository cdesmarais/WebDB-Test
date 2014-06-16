if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantGetByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantGetByID]
GO

CREATE Procedure dbo.DNRestaurantGetByID
 (
  @RestaurantID int
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT 
	r.RID AS RestaurantID
	,r.RName AS RestaurantName
	,r.RSName
	,r.Address1 AS Address1
	,r.Address1 AS Address2
	,r.City,r.State
	,r.Zip AS Zip
	,c.countryID
	,c.countryCode
	,c.countryName	
	,rm.RMDesc as Description
	,r.ExternalURL AS URL
	,r.CrossStreet AS CrossStreet
	,rm.ParkingDescription AS Parking
	,rs.RState AS RestaurantState
	,rs.RestStateID AS RestStateID
	,'(' + Left(r.ReservationPhone,3) + ') ' + Left(Right(r.ReservationPhone,7),3) + '-' + Right(r.ReservationPhone,4) AS Phone
	,r.AcceptCheque As Cheque
	,n.metroareaid as Metro_Area_ID
	,mao.Days AS MaxAdvanceDays
	,r.IsReachable as HasHeartbeat
	,r.latitude
	,r.longitude
	,r.RestaurantType

FROM		RestaurantVW r
INNER JOIN	CountryAVW c
		ON	c.CountryID = r.Country
and			c.LanguageID = r.LanguageID		
INNER JOIN  RestaurantState rs
		ON	r.RestStateID = rs.RestStateID 
INNER JOIN	RestaurantMessageAVW rm
		ON  r.RID = rm.RID
and			r.LanguageID = rm.LanguageID
INNER JOIN	Neighborhood n 
		ON	r.neighborhoodid = n.neighborhoodid
inner join MaxAdvanceOption mao
		on r.MaxAdvanceOptionID = mao.MaxAdvanceOptionID
WHERE (r.RID = @RestaurantID)
ORDER BY r.RName

GO

GRANT EXECUTE ON [DNRestaurantGetByID] TO ExecuteOnlyRole

GO

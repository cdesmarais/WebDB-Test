if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantGetAll]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantGetAll]
GO

CREATE Procedure dbo.RestaurantGetAll
As

SET NOCOUNT ON
set transaction isolation level read uncommitted

SELECT 
    r.RID as  RestaurantID
    ,r.RName AS RestaurantName
    ,r.Address1 AS Address
	,r.City,
    r.State,r.Zip AS Zip,
    rm.RMDesc as Description,
    r.ExternalURL AS URL,
    rs.RState AS RestaurantState,
    '(' + Left(r.ReservationPhone,3) + ') ' + Left(Right(r.ReservationPhone,7),3) + '-' + Right(r.ReservationPhone,4) AS Phone,
    r.AcceptCheque As Cheque,
    n.metroareaid as Metro_Area_ID,
    r.RestStateID as RestStateID
FROM RestaurantVW r
INNER JOIN RestaurantState rs
ON   	r.RestStateID = rs.RestStateID
INNER JOIN RestaurantMessageAVW rm 
ON r.RID = rm.RID
and	r.LanguageID = rm.LanguageID
INNER JOIN NeighborhoodAVW n 
ON   	r.neighborhoodid = n.neighborhoodid
and		r.LanguageId = n.LanguageID
Where r.RestStateID in (1,2,5,6,7)
ORDER BY r.RName

GO

GRANT EXECUTE ON [RestaurantGetAll] TO ExecuteOnlyRole

GO

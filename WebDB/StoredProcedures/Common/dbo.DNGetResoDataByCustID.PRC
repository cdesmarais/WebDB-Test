if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetResoDataByCustID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetResoDataByCustID]
GO

CREATE PROCEDURE dbo.DNGetResoDataByCustID
(
    @CustID int
)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

select		res.ResID
		,	r.RID
		,	res.CustID
		,	r.RName as Restname
		,	n.MetroAreaID				
		,	res.ResPoints
		,	res.ShiftDate + 2 + res.ResTime as ReservationDate
		,   res.RStateID
from		Reservation res
inner join 	RestaurantAVW r 	
on			r.RID					= res.RID
and			r.LanguageID			= res.LanguageID
inner join 	Neighborhood n 
on			n.NeighborhoodID		= r.NeighborhoodID
where		res.CustID				= @CustID

GO


GRANT EXECUTE ON [DNGetResoDataByCustID] TO ExecuteOnlyRole

GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Concierge_Reservation_By_ConfirmNumber]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Concierge_Reservation_By_ConfirmNumber]
GO

CREATE Procedure dbo.Concierge_Reservation_By_ConfirmNumber
 (
	@RestaurantID INT
	,@ConfirmNumber INT
	,@CallerID INT
 )
As

SET NOCOUNT ON
set transaction isolation level read uncommitted


SELECT	r.ResID
		,rest.RName
		,r.RStateID
		,c.FName
		,c.LName
		,c.CompanyID
FROM		Reservation r
INNER JOIN	RestaurantVW rest
ON		r.RID = rest.RID
INNER JOIN	Caller c
on		r.CallerID = c.CallerID
WHERE		r.RID = @RestaurantID
AND		r.ConfNumber = @ConfirmNumber
AND		r.CallerID = @CallerID

GO

GRANT EXECUTE ON [Concierge_Reservation_By_ConfirmNumber] TO ExecuteOnlyRole

GO




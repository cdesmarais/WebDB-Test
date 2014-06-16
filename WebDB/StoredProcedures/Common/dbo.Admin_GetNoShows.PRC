if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetNoShows]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetNoShows]
GO

CREATE PROCEDURE dbo.Admin_GetNoShows
(
  @IsCaller int
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRANSACTION

if @IsCaller = 0
  Begin
  select		Customer.CustID as customer_id,
				FName as first_name,
				LName as last_name,
				Customer.email,
				convert(int,Customer.active,4) as status,
				count(ResID) as NoShowCount
  from			Customer 
  inner join	Reservation 
  on			Customer.CustID = Reservation.CustID
  inner join	RestaurantAVW r 
  on			Reservation.RID = r.RID
  and			Reservation.LanguageID = r.LanguageID
  inner join	NeighborhoodLocal n 
  on			r.neighborhoodid = n.neighborhoodid 
  and			n.LanguageID = r.LanguageID
  where			RStateID = 4
  group by		Customer.CustID,
				Customer.FName,
				Customer.LName,
				Customer.email,
				convert(int,Customer.active,4)
  Having		count(ResID) > 2
  order by		NoShowCount desc,
				LName
  End
if (@@ERROR <> 0)
	goto general_error
if @IsCaller > 0
  Begin
  select		Caller.CallerID as Caller_ID ,
				FName as first_name,
				LName as last_name,
				Caller.LoginName as login_name,
				convert(int,Caller.callerstatusid,4) as status,
				count(ResID) as NoShowCount
  from			caller
  inner join	Reservation 
  on			Caller.CallerID = Reservation.CallerID
  inner join	RestaurantAVW r 
  on			Reservation.RID = r.RID
  and			Reservation.LanguageID = r.LanguageID
  inner join	NeighborhoodLocal n 
  on			n.neighborhoodid = r.neighborhoodid 
  and			n.LanguageID = r.LanguageID
  where			RStateID = 4
  and			PositionID = 3
  group by		Caller.CallerID,
				Caller.FName,
				Caller.LName,
				Caller.LoginName,
				convert(int,Caller.callerstatusid,4)
  Having		count(ResID) > 3
  order by		NoShowCount desc,
				LName
  End
if (@@ERROR <> 0)
	goto general_error

COMMIT TRANSACTION
Return(0)

general_error:
	ROLLBACK TRANSACTION
	Return(0)
GO

GRANT EXECUTE ON [Admin_GetNoShows] TO ExecuteOnlyRole

GO

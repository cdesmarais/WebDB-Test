if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetCountPendingResosByCustomerID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetCountPendingResosByCustomerID]
GO

CREATE PROCEDURE dbo.Admin_GetCountPendingResosByCustomerID 

 @CustomerID int
,@IsCaller bit

AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


IF @IsCaller = 0
   select count(*) as resos 
   from Reservation 
   where CustID = @CustomerID 
   and RStateID in (select RStateID from ReservationState where RStateID not in (3,4,8,9,10))

IF @IsCaller = 1
   BEGIN
      select count(*) as resos 
      from Reservation 
      where CustID in (Select CustID from CallerCustomer where CallerID = @CustomerID) 
      and RStateID in  (select RStateID from ReservationState where RStateID not in (3,4,8,9,10))
   END

GO


GRANT EXECUTE ON [Admin_GetCountPendingResosByCustomerID] TO ExecuteOnlyRole

GO

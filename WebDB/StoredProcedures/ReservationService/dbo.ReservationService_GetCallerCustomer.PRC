if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ReservationService_GetCallerCustomer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ReservationService_GetCallerCustomer]
GO

create procedure dbo.ReservationService_GetCallerCustomer
(
	@CustID int
)
as
set nocount on
set transaction isolation level read uncommitted

select		top 1	
			CustID,
      		FName,
      		LName,
      		SFname,
      		SLname,
      		EMail,
      		CallerID
from		CallerCustomer
where		CustID = @CustID

go

grant execute on [ReservationService_GetCallerCustomer] to ExecuteOnlyRole

GO
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetLimitedBookingRestaurants]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetLimitedBookingRestaurants]
GO

CREATE PROCEDURE dbo.GetLimitedBookingRestaurants

AS
SET NOCOUNT ON

Select	LimitedBooking,
		RID as Restaurant_ID
from	 Restaurant
where	 LimitedBooking = 1

GO


GRANT EXECUTE ON [GetLimitedBookingRestaurants] TO ExecuteOnlyRole

GO

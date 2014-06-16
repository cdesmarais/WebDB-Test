if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantGetLimitedBooking]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantGetLimitedBooking]
GO

CREATE PROCEDURE dbo.DNRestaurantGetLimitedBooking

AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

Select	 LimitedBooking
		,RID 
from	 Restaurant
where	 LimitedBooking = 1

GO



GRANT EXECUTE ON [DNRestaurantGetLimitedBooking] TO ExecuteOnlyRole

GO

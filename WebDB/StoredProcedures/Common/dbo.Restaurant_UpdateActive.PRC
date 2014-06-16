if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_UpdateActive]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_UpdateActive]
GO

CREATE Procedure dbo.Restaurant_UpdateActive
 (
  @Restaurants varchar(8000) --[EV: List of Int IDs]
 )
As

SET NOCOUNT ON


Declare @DateNow as datetime, @UTCNow as datetime -- Add UTCNow to track LTC_UTC field

Select @DateNow = GetDate(), @UTCNow = GetUTCDate()

UPDATE LastTimeContacted --with (UPDLOCK)
SET    LTC = @DateNow,
	   LTC_UTC = @UTCNow
WHERE  CHARINDEX(',' + CAST(RID AS varchar(16)) + ',',@Restaurants) > 0
OPTION (KEEPFIXED PLAN)
GO

GRANT EXECUTE ON [Restaurant_UpdateActive] TO ExecuteOnlyRole

GO

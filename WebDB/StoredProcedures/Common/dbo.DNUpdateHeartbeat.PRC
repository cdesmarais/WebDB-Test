if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUpdateHeartbeat]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUpdateHeartbeat]
GO

CREATE PROCEDURE dbo.DNUpdateHeartbeat
(
	@nRestaurantID int
	,@sCommType nvarchar(50)
)
 AS
Declare @DateNow as datetime, @UTCNow as datetime

Select @DateNow = GetDate(), @UTCNow = GetUTCDate()

SET NOCOUNT ON

UPDATE LastTimeContacted 
SET LTC = @DateNow,
	LTC_UTC = @UTCNow
WHERE RID = @nRestaurantID
and DateDiff(mi,@UTCNow, LTC_UTC) < -4


GO


GRANT EXECUTE ON [DNUpdateHeartbeat] TO ExecuteOnlyRole

GO

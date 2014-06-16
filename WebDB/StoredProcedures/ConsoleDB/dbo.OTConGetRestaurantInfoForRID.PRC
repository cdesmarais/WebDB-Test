if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTConGetRestaurantInfoForRID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTConGetRestaurantInfoForRID]
GO

CREATE Procedure dbo.OTConGetRestaurantInfoForRID

@RID	INT

AS

--
-- Gets allotment restaurant data for the given RID from WebDB
--

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT	r.RID,
		r.TZID,
		tz.ServerToLocalOffsetMi AS 'ServerTimeToLocalTimeOffsetMinutes',
		r.Country,
		r.RName AS RestaurantName,
		r.MinOnlineOptionID AS 'MinPartySize',
		r.MaxLargePartyID AS 'MaxPartySize',
		r.BrandID,
		r.IsConnectFieldTest
FROM	RestaurantVW r
  INNER JOIN	TimezoneVW tz ON tz.TZID = r.TZID
WHERE	r.RestaurantType = 'A'
AND		r.RID = @RID
GO

GRANT EXECUTE ON [OTConGetRestaurantInfoForRID] TO ConsoleExecuteRole

GO


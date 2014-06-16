if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OTConDNCacheRestaurantInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OTConDNCacheRestaurantInfo]
GO

CREATE Procedure dbo.OTConDNCacheRestaurantInfo

AS

--
-- Gets allotment restaurant data from WebDB
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
		r.BrandID
FROM	RestaurantVW r
  INNER JOIN	TimezoneVW tz ON tz.TZID = r.TZID
WHERE	r.RestaurantType = 'A'
GO

GRANT EXECUTE ON [OTConDNCacheRestaurantInfo] TO ConsoleExecuteRole

GO


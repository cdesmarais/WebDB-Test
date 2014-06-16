if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procOTConDNCacheRestaurantInfoForBrandID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procOTConDNCacheRestaurantInfoForBrandID]
GO

CREATE Procedure dbo.procOTConDNCacheRestaurantInfoForBrandID

@BrandID INT

AS

--
-- Gets allotment restaurant data from WebDB for the given BrandID
--

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

IF NOT EXISTS (SELECT 1 FROM Brand WHERE BrandID = @BrandID)
BEGIN
	DECLARE @ERRMSG NVARCHAR(256)
	SET	@ERRMSG = 'dbo.procOTConDNCacheRestaurantInfoForBrandID: No such BrandID:' + CAST(@BrandID AS NVARCHAR(3))
	RAISERROR(@ERRMSG, 16, 1)
END
ELSE
BEGIN
	SELECT	r.RID,
			r.TZID,
			tz.ServerToLocalOffsetMi AS 'ServerTimeToLocalTimeOffsetMinutes',
			r.Country,
			r.RName AS RestaurantName,
			r.MinOnlineOptionID AS 'MinPartySize',
			r.MaxLargePartyID AS 'MaxPartySize',
			r.BrandID,
			tz._offsetMI AS 'GMTTimeToLocalTimeOffsetMinutes',
			r.Phone,
			r.IsConnectFieldTest
	FROM	RestaurantVW r
	  INNER JOIN	TimezoneVW tz ON tz.TZID = r.TZID
	WHERE	r.RestaurantType = 'A'
	AND		r.BrandID = @BrandID
END
GO

GRANT EXECUTE ON [procOTConDNCacheRestaurantInfoForBrandID] TO ConsoleExecuteRole

GO
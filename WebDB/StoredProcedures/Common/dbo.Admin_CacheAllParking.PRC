if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_CacheAllParking]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_CacheAllParking]
GO


CREATE PROCEDURE dbo.Admin_CacheAllParking
As
SET NOCOUNT ON
SELECT 	ParkingID AS ParkingID,
	Parking AS ParkingName,
	LanguageID
FROM [ParkingLocal]
ORDER BY ParkingName

GO

GRANT EXECUTE ON [Admin_CacheAllParking] TO ExecuteOnlyRole

GO

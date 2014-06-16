if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantImporter_GetAllRestaurantMessages]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantImporter_GetAllRestaurantMessages]
GO

CREATE PROCEDURE [dbo].[RestaurantImporter_GetAllRestaurantMessages] AS

set transaction ISOLATION LEVEL read UNCOMMITTED

SELECT	RID
		,Hours AS Hours
		,SpecialEvents AS SpecialEvents
		,ParkingDescription AS ParkingDescription
		,CaterDescription as Cater_Description
		,PublicTransit AS PublicTransit
		,PrivatePartyDescription AS PrivatePartyDescription
		,BanquetDescription AS BanquetDescription
		,Entertainment
		,SpecialEventsStartDate
		,SpecialEventsEndDate
		,PrivatePartyLongDecription AS PrivatePartyLongDescription
		,LanguageID
		,Entertainment
FROM RestaurantMessageAVW

option (ROBUST PLAN)

GO

GRANT EXECUTE ON [dbo].[RestaurantImporter_GetAllRestaurantMessages] TO ExecuteOnlyRole

GO

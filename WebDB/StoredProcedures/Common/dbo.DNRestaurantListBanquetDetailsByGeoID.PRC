if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantListBanquetDetailsByGeoID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantListBanquetDetailsByGeoID]
GO

--*************************************
--** OBSOLETED: EV: In i18n Phase2
--*************************************


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantListByFoodTypesPricesAndMacroNeighborhoods]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantListByFoodTypesPricesAndMacroNeighborhoods]
GO
--*****************************************************
--** EV: 08/06/2004: This proc is obsolete
--** Replaced by DNRestaurantSearchList and DNRestaurantSearchTime
--** Runtime join and filter is done in WebServer
--*****************************************************

--** Code Officially Obsoleted in tag: Web_4_4_4

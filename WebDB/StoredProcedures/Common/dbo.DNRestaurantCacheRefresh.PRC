
--*********************************************************
--** Refreshes the 30 Restaurant Search Cache
--** Should be called immediately after restaurant heartbeats are updated
--*********************************************************
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantCacheRefresh]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantCacheRefresh]
GO

--*******************************
--** EV: Obsoleted; i18n
--*******************************

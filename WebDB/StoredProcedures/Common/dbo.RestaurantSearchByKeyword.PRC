if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantSearchByKeyword]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantSearchByKeyword]
GO

--******************************************
--** OBSOLETED: EV: i18n phase2
--******************************************


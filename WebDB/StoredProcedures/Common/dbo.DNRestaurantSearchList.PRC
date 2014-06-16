if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantSearchList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantSearchList]
GO

--*********************************
--** OBSOLETE: EV: Obsoleted as part of i18n
--*********************************


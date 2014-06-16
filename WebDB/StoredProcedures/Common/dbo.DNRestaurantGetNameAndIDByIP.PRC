if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantGetNameAndIDByIP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantGetNameAndIDByIP]
GO

--****************************************
--** OBSOLETE: EV: Obsoleted in i18n
--****************************************


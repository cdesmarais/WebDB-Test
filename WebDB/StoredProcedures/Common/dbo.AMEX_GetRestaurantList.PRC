if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AMEX_GetRestaurantList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AMEX_GetRestaurantList]
GO

--************************
--** OBSOLETED: In i18n Phase2
--************************

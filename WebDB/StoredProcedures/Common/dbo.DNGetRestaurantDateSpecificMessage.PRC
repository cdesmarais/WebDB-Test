if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetRestaurantDateSpecificMessage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetRestaurantDateSpecificMessage]
GO

--**************************
--** OBSOLETE: EV: Obsoleted during i18n
--**************************


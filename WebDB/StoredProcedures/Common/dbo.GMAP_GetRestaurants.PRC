
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GMAP_GetRestaurants]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GMAP_GetRestaurants]
GO

--***************************
--** OBSOLETED: EV: This proc is never used. Obsoleted in i18n phase 2
--***************************

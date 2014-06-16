if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_GetEmptyLongLat]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_GetEmptyLongLat]
GO

--***********************************************
--** OBSOLETE: EV: i18n Phase2
--***********************************************

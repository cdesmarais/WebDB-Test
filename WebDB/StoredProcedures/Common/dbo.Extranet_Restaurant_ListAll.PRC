if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Extranet_Restaurant_ListAll]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Extranet_Restaurant_ListAll]
GO
--*********************************
--** OBSOLETE: EV: i18n phase2
--*********************************


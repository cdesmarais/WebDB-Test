if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[XML_ErrorGetByLanguageID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[XML_ErrorGetByLanguageID]
GO

--******************************************
--** OBSOLETE: EV: i18n phase2
--******************************************


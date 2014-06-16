if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Allotment_Restaurant_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Allotment_Restaurant_Add]
GO

--***************************************
--** OBSOLETE: Removed in i18n phase2
--***************************************

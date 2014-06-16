if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Allotment_Restaurant_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Allotment_Restaurant_Update]
GO

--*****************************************
--** OBSOLETE: EV: i18n phasse 2
--*****************************************


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Allotment_DaySchedule_Add]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Allotment_DaySchedule_Add]
GO



--***************************************
--** OBSOLETE: EV: Old style Allotment obsolete; replaced with console 11/30/2009
--***************************************

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_GetByID_WithCC]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_GetByID_WithCC]
GO

--***********************************************
--** OBSOLETE: As of i18n Phase2
--** Proc can be dropped from CVS after i18np2 deployed
--***********************************************



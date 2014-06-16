if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_AddAllotment]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_AddAllotment]
GO

--*************************************
--** OBSOLETE: EV: i18n Phase2
--*************************************

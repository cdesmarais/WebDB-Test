if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNReservationUpdateForChange]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNReservationUpdateForChange]
GO
--************************************************
--** OBSOLETE: EV: i18n Phase 2
--************************************************


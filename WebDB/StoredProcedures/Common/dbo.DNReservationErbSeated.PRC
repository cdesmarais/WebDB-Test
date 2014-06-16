if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNReservationErbSeated]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNReservationErbSeated]
GO
--***************************************************8
--** DNReservationErbSeated is deprecated - use Reservation_ErbSeated instead. 
--** OBSOLETED: EV: in i18n Phase 2
--***************************************************8

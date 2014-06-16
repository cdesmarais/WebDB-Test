if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNReservationAdd]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNReservationAdd]
GO

--***********************************************
--** OBSOLETE: EV: Obsoleted i18n phase 2
--***********************************************

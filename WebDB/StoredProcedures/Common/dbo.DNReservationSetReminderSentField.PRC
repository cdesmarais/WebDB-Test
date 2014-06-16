if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNReservationSetReminderSentField]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNReservationSetReminderSentField]
GO

--********************************
--** OBSOLETE: EV 11/12/07: This proc should be obsolete -- they are caled from RestaurantUpdatesWS
--********************************

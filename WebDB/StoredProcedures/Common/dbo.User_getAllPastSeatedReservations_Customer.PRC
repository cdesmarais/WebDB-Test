if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_getAllPastSeatedReservations_Customer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_getAllPastSeatedReservations_Customer]
GO

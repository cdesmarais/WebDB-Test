if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[User_getAllPastSeatedReservations_Caller]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[User_getAllPastSeatedReservations_Caller]
GO

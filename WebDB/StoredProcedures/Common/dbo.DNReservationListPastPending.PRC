if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNReservationListPastPending]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNReservationListPastPending]
GO

--****************************************
--** OBSOLETE: EV: i18n Phase2 (removed corresponding dotnet code)
--****************************************

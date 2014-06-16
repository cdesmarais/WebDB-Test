if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reservation_GetLast48hoursCancelledByRestaurantID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reservation_GetLast48hoursCancelledByRestaurantID]
GO

--************************************************
--** OBSOLETE: Part of Legacy / Pre-console Allotment
--************************************************
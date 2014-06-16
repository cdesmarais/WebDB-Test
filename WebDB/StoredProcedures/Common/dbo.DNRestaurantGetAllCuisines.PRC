if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantGetAllCuisines]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantGetAllCuisines]
GO

--*********************************************************
--**EV: 5/4/2006 This proc will be obsolete once 4.2.6.x is deployed
--**OBSOLETED: EV: In i18n Phase2
--*********************************************************


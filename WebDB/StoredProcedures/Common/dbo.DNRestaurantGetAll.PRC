if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantGetAll]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantGetAll]
GO


--*****************
--EV: 5/4/2006 This proc will be obsolete once 4.2.6.x is deployed
--** OBSOLETE: Officially obsoleted in i18n
--*****************


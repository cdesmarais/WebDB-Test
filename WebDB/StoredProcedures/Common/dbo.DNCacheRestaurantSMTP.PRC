if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheRestaurantSMTP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheRestaurantSMTP]
GO

--*****************************
--** OBSOLETE: EV: 8/4/2006
--*****************************

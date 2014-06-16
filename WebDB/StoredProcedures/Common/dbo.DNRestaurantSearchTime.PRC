if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNRestaurantSearchTime]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNRestaurantSearchTime]
GO


--*********************************************************
--** EV: 01/11/07: Obsolete: Removed in tag: Web_4_4_4
--*********************************************************

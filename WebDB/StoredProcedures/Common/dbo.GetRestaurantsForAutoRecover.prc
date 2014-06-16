if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetRestaurantsForAutoRecover]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetRestaurantsForAutoRecover]
GO

--*********************************************************
--** OBSOLETE: EV: Obosleted as of Aggregator Redesign 6/16/2008
--*********************************************************

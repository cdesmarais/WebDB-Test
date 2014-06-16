if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNAllotmentAvailabilityCheck]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNAllotmentAvailabilityCheck]
GO

--********************************
--** OBSOLETE: 11/30/2009: This is legacy allotmnet (pre-console) never supported in consumer site
--********************************
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobUpdateAGGDashboardTBL]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobUpdateAGGDashboardTBL]
GO

--******************************
--** OBSOLETE: 1/24/2011
-- TT44121 - AV
--******************************

GO

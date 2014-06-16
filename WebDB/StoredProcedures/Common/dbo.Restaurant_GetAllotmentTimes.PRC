if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_GetAllotmentTimes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_GetAllotmentTimes]
GO

--***************************************
--** OBSOLETE: Pre-console (oblsoeted in 2007)
--***************************************

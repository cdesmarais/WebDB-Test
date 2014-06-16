if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_GetListForAllotmentNotification]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_GetListForAllotmentNotification]
GO

--***************************************
--** OBSOLETE: Pre-console (oblsoeted in 2007)
--***************************************

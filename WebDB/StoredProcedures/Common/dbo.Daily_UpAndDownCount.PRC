if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Daily_UpAndDownCount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Daily_UpAndDownCount]
GO

--******************************
--** OBSOLETE: 11/30/2009
--******************************
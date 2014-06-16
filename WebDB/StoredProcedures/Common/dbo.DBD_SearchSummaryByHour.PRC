
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DBD_SearchSummaryByHour]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DBD_SearchSummaryByHour]
GO

--*******************************
--** OBSOLETE: Proc dead when logs went to LogDB
--*******************************


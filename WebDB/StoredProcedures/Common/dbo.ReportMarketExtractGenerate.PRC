if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ReportMarketExtractGenerate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ReportMarketExtractGenerate]
GO
--
--OBSOLETE: I18n build JH SEPT MOVED TO OTREPORTS 
--


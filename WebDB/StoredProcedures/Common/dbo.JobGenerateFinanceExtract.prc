/****** Object:  StoredProcedure [dbo].[JobGenerateFinanceExtract]    Script Date: 05/23/2011 10:16:43 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[JobGenerateFinanceExtract]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[JobGenerateFinanceExtract]
GO

--**************************************
--** OBSOLETE: Unused proc (all commented out) discovered during regional split work
--** CMD: 05/23/2011
--**************************************


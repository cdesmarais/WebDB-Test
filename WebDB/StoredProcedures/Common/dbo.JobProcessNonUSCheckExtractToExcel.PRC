if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobProcessNonUSCheckExtractToExcel]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobProcessNonUSCheckExtractToExcel]
GO

--Procedure is obsolete 
--Replaced by jobProcessNonWFBCheckExtractToExcel
--Feb 25, 2008 JHwang

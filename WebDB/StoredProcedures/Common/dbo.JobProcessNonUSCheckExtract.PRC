if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobProcessNonUSCheckExtract]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobProcessNonUSCheckExtract]
GO

--Procedure is obsolete 
--Replaced by jobProcessNonWFBCheckExtract
--Feb 25, 2008 JHwang






if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobCommitUSCheckExtract]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobCommitUSCheckExtract]
GO
--Procedure is obsolete 
--Replaced by jobProcessCommitWFBCheckExtract
--Feb 25, 2008 JHwang

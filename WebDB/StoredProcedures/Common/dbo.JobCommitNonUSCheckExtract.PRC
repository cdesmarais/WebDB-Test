if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[JobCommitNonUSCheckExtract]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[JobCommitNonUSCheckExtract]
GO
--Procedure is obsolete 
--Replaced by jobProcessCommitWFBCheckExtract
--Feb 25, 2008 JHwang

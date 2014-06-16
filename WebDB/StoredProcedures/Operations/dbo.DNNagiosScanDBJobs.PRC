if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNNagiosScanDBJobs]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNNagiosScanDBJobs]
GO

--********************************
--** EV: This proc has been OBSOLETEd as of SQL2008 migration 10/11/2009
--********************************


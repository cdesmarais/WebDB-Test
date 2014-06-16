if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNGetAllNoShowResos]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNGetAllNoShowResos]
GO

--************************************
--** OBSOLETE: Proc replaced by an svcProc
--** EV: 10/14/2007
--************************************

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_JobAdd]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_JobAdd]
GO

--Deprecated part of TT #27025
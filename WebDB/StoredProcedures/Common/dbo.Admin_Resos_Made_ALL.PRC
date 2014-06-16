if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Resos_Made_ALL]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Resos_Made_ALL]
GO

--Obsolete, Procedure to be dropped
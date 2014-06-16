if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetAllMetroAreas]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetAllMetroAreas]
GO


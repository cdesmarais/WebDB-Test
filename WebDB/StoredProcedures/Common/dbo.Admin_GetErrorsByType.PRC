if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetErrorsByType]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetErrorsByType]
GO


--************************
--** OBSOLETED: In i18n Phase2
--************************
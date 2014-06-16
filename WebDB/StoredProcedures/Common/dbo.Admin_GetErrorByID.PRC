if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetErrorByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetErrorByID]
GO

--************************
--** OBSOLETED: In i18n Phase2
--************************
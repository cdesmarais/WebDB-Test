if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_UpdateError]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_UpdateError]
GO

--************************************
--** OBSOLETE: As of i18n Phase2
--************************************


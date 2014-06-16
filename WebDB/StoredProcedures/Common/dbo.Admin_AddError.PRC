if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_AddError]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_AddError]
GO

--*********************************
--** OBSOLETE as of i18n Phase2
--*********************************


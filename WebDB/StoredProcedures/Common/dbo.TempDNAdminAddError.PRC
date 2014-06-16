GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TempDNAdminAddError]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[TempDNAdminAddError]
GO
--**********************************************
--** OBSOLETE: EV: i18n Phase2
--**********************************************

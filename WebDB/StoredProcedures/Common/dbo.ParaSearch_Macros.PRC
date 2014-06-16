GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ParaSearch_Macros]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ParaSearch_Macros]
GO

--*****************************************
--** OBSOLETE: EV: i18n Phase2
--*****************************************


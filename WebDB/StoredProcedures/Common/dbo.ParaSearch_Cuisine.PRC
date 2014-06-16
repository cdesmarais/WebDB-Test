if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ParaSearch_Cuisine]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ParaSearch_Cuisine]
GO

--*************************************
--** OBSOLETE: EV: Obsoleted i18n Phase2
--*************************************

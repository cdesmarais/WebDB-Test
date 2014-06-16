if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ParaSearch_Offers]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ParaSearch_Offers]
GO

--*****************************************
--** OBSOLETE: EV: i18n Phase2
--*****************************************

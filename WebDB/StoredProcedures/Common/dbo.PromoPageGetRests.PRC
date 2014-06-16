if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PromoPageGetRests]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PromoPageGetRests]
GO

--***************************
--** OBSOLETE: EV: in i18n phase2
--***************************

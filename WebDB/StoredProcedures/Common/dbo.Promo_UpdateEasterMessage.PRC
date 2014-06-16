
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Promo_UpdateEasterMessage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Promo_UpdateEasterMessage]
GO


--*********************************
--** OBSOLETE as of i18n MX
--*********************************


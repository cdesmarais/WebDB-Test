
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Promo_UpdateValentinesDayMessage]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Promo_UpdateValentinesDayMessage]
GO

--*********************************
--** OBSOLETE as of i18n MX
--*********************************


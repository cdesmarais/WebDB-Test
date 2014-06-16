
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantUpdateGroups]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantUpdateGroups]
GO

--******************************************
--** OBSOLETED as of i18n Phase 2
--******************************************

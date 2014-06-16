if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FoodType_ListAll]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[FoodType_ListAll]
GO

--**************************************
--** OBSOLETE: EV: i18n Phase2
--**************************************

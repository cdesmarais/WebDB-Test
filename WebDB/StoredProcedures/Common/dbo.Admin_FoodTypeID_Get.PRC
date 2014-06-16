if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_FoodTypeID_Get]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_FoodTypeID_Get]
GO
--*************************************
--** EV: OBSOLETED i18n phase 2
--*************************************


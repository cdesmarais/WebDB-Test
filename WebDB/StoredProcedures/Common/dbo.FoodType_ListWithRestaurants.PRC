if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FoodType_ListWithRestaurants]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[FoodType_ListWithRestaurants]
GO

--**************************************************************************************
--** Proc marked for deletion TT: 22393
--**
--** OBSOLETE WR10_4
--**************************************************************************************

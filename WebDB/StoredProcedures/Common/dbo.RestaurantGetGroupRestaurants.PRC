if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RestaurantGetGroupRestaurants]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RestaurantGetGroupRestaurants]
GO

--**************************************************************************************
--** Proc marked for deletion TT: 22393
--**
--** OBSOLETE WR10_4
--**************************************************************************************

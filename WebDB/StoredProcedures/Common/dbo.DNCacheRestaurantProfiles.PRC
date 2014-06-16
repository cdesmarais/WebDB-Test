if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheRestaurantProfiles]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheRestaurantProfiles]
GO


--**************************************************************************************
--** Proc marked for deletion TT: 22393
--**
--** OBSOLETE WR10_4
--**************************************************************************************

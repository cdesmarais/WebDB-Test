if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCacheRestaurantSearchList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCacheRestaurantSearchList]
GO

--***************************************
--** Proc is obsolete
--***************************************
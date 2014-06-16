if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_Get_Similar_Rests]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_Get_Similar_Rests]
GO

--*******************************************************
--** OBSOLETE: This proc was removed in WR82009
--*******************************************************

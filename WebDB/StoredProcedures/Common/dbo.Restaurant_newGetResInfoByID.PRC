if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_newGetResInfoByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_newGetResInfoByID]
GO

-- DELETED per TT 29353 for WR2009 R3 mmc

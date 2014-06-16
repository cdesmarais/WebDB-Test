if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetMetroHeaderTagsForMetro]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetMetroHeaderTagsForMetro]
GO


--  *** DELETED FOR Web_9_8 PER TT 32824 mmc


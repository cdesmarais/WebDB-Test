if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateMetroHeaderTagsForMetro]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateMetroHeaderTagsForMetro]
GO


 -- *** DELETED FOR Web_9_8 PER TT 32824 mmc

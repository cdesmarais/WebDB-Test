if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[procUpdateCHARMCovers]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[procUpdateCHARMCovers]
/* This procedure is deprecated and should be removed */

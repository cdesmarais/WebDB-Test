if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNCheckSearchRate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNCheckSearchRate]
GO


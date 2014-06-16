
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetValueLookupsByType]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetValueLookupsByType]
GO

--*******************************
--** Proc deprecated in WR9
--*******************************

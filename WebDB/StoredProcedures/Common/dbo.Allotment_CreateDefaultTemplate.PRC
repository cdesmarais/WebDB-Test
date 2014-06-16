if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Allotment_CreateDefaultTemplate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Allotment_CreateDefaultTemplate]
GO


--***************************************
--** OBSOLETE: EV: Old style Allotment obsolete; replaced with console 11/30/2009
--***************************************

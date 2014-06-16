if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Allotment_Shift_update_Template]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Allotment_Shift_update_Template]
GO


--***************************************
--** OBSOLETE: EV: Old style Allotment obsolete 1/1/2007; replaced with console 11/30/2009
--***************************************

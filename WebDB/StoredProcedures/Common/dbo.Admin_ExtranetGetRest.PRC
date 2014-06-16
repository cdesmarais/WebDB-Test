if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ExtranetGetRest]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ExtranetGetRest]
GO

--*****************************************
--** OBSOLETE: BC: Web_Feature_SOXR1
--*****************************************

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Extranet_Admin_ResetPassword]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Extranet_Admin_ResetPassword]
GO

--*****************************************
--** OBSOLETE: BC: Web_Feature_SOXR1
--*****************************************

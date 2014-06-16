if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Extranet_User_ChangePassword]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Extranet_User_ChangePassword]
GO

--*****************************************
--** OBSOLETE: BC: Web_Feature_SOXR1
--*****************************************

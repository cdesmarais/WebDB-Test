if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Extranet_User_Login]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Extranet_User_Login]
GO

--****************************
--** OBSOLETE: EV: i18n phase 2
--****************************

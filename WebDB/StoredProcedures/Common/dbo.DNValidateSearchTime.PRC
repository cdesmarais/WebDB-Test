if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNValidateSearchTime]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNValidateSearchTime]
GO

--********************************
--** OBSOLETE: i18n phase2
--********************************


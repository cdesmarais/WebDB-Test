if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNUserAcctSum]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNUserAcctSum]
GO

--**************************
--** OBSOLETE: EV: i18n Phase2
--**************************


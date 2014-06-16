if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DNAllotmentGetTimes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DNAllotmentGetTimes]
GO
--**********************************
--** OBSOLETE: EV: I18n Phase2 
--**********************************


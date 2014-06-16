if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_SendAllotmentNotification]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_SendAllotmentNotification]
GO


--**********************************
--** OBSOLETE: Legacy Allotment 2007 (pre-console)
--**********************************

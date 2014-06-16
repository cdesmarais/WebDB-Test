if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Restaurant_SwitchFromErbToDSLBridgeAllotment]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Restaurant_SwitchFromErbToDSLBridgeAllotment]
GO

--**********************************
--** OBSOLETE: Legacy Allotment 2007 (pre-console)
--**********************************

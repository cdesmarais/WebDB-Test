if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Notification_List]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Notification_List]
GO


--**************************************
--** OBSOLETE: Allotment no longer supported
--** EV: 10/14/2007
--**************************************



